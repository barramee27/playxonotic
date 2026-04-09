import { useState, useEffect } from 'react';
import { useAuth } from '../context/AuthContext';
import { Navigate } from 'react-router-dom';

export default function Play() {
  const { user, token, loading, refreshUser } = useAuth();
  const [launched, setLaunched] = useState(false);
  const [highestEver, setHighestEver] = useState(0);
  const [statsLoading, setStatsLoading] = useState(true);

  useEffect(() => {
    // Fetch highest ever games played
    const fetchStats = async () => {
      try {
        const response = await fetch('/api/auth/stats', {
          headers: {
            'Authorization': `Bearer ${token}`,
          },
        });
        if (response.ok) {
          const data = await response.json();
          setHighestEver(data.highestEver || 0);
        }
      } catch (err) {
        console.error('Failed to fetch stats:', err);
      } finally {
        setStatsLoading(false);
      }
    };

    if (token) {
      fetchStats();
    }
  }, [token]);

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center pt-16">
        <p className="text-xon-muted text-lg">Loading...</p>
      </div>
    );
  }

  if (!user) return <Navigate to="/login" />;

  const gameUrl = `/game/darkplaces-wasm.html?token=${encodeURIComponent(token)}&name=${encodeURIComponent(user.username)}`;

  const handleLaunch = async () => {
    // Increment games played counter
    try {
      const response = await fetch('/api/auth/increment-games', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
      });
      if (response.ok) {
        const data = await response.json();
        // Update highest ever if this user now has the record
        if (data.highestEver > highestEver) {
          setHighestEver(data.highestEver);
        }
        // Refresh user data to show updated gamesPlayed
        if (refreshUser) {
          refreshUser();
        }
      }
    } catch (err) {
      console.error('Failed to increment games:', err);
    }
    
    window.open(gameUrl, '_blank');
    setLaunched(true);
  };

  return (
    <div className="min-h-screen flex items-center justify-center px-4 pt-16">
      <div className="max-w-lg w-full text-center">
        <div className="bg-xon-card border border-xon-border rounded-2xl p-10 shadow-2xl">
          <div className="w-20 h-20 rounded-2xl bg-gradient-to-br from-xon-primary to-orange-600 flex items-center justify-center text-4xl font-bold text-white mx-auto mb-6">
            X
          </div>

          <h1 className="text-3xl font-bold text-white mb-2">Ready to Play?</h1>
          <p className="text-xon-muted mb-2">
            Logged in as <span className="text-xon-accent font-medium">{user.username}</span>
          </p>
          <p className="text-xon-muted text-sm mb-8">
            The game will load in your browser. First load may take a moment while assets download.
          </p>

          <button
            onClick={handleLaunch}
            className="px-10 py-4 rounded-xl bg-gradient-to-r from-xon-primary to-orange-600 text-white text-xl font-bold hover:from-xon-primary-hover hover:to-orange-700 transition-all shadow-2xl shadow-orange-500/30 hover:shadow-orange-500/50 hover:scale-105"
          >
            {launched ? 'Game Opened - Click to Relaunch' : 'Launch Xonotic'}
          </button>

          <div className="mt-8 grid grid-cols-2 gap-4 text-left">
            <div className="bg-xon-darker rounded-lg p-4 border border-xon-border">
              <p className="text-xs text-xon-muted uppercase tracking-wide mb-1">Games Played</p>
              <p className="text-xl font-bold text-white">{user.gamesPlayed || 0}</p>
            </div>
            <div className="bg-xon-darker rounded-lg p-4 border border-xon-border">
              <p className="text-xs text-xon-muted uppercase tracking-wide mb-1">Member Since</p>
              <p className="text-xl font-bold text-white">
                {new Date(user.createdAt).toLocaleDateString('en-US', { month: 'short', year: 'numeric' })}
              </p>
            </div>
          </div>
          
          <div className="mt-4 grid grid-cols-2 gap-4 text-left">
            <div className="bg-xon-darker rounded-lg p-4 border border-xon-border">
              <p className="text-xs text-xon-muted uppercase tracking-wide mb-1">Highest Ever</p>
              <p className="text-xl font-bold text-xon-accent">
                {statsLoading ? '...' : highestEver}
              </p>
            </div>
            <div className="bg-xon-darker rounded-lg p-4 border border-xon-border">
              <p className="text-xs text-xon-muted uppercase tracking-wide mb-1">Your Rank</p>
              <p className="text-xl font-bold text-white">
                {statsLoading ? '...' : (user.gamesPlayed || 0) >= highestEver && highestEver > 0 ? '🏆 #1' : '—'}
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
