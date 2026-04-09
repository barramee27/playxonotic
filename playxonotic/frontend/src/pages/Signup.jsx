import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export default function Signup() {
  const [username, setUsername] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const { signup } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    if (password !== confirmPassword) {
      setError('Passwords do not match');
      setLoading(false);
      return;
    }

    try {
      await signup(username, email, password);
      navigate('/');
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center px-4 pt-16">
      <div className="w-full max-w-md">
        <div className="bg-xon-card border border-xon-border rounded-2xl p-8 shadow-2xl">
          <div className="text-center mb-8">
            <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-xon-primary to-orange-600 flex items-center justify-center font-bold text-white text-xl mx-auto mb-4">
              X
            </div>
            <h1 className="text-2xl font-bold text-white">Create Account</h1>
            <p className="text-xon-muted text-sm mt-1">Join the arena</p>
          </div>

          {error && (
            <div className="bg-red-500/10 border border-red-500/30 rounded-lg px-4 py-3 mb-6">
              <p className="text-red-400 text-sm">{error}</p>
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-5">
            <div>
              <label className="block text-sm font-medium text-xon-muted mb-1.5">Username</label>
              <input
                type="text"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                required
                minLength={3}
                maxLength={20}
                className="w-full px-4 py-3 rounded-lg bg-xon-darker border border-xon-border text-white placeholder-xon-muted/50 focus:outline-none focus:border-xon-primary focus:ring-1 focus:ring-xon-primary transition-colors"
                placeholder="Choose a username"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-xon-muted mb-1.5">Email</label>
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                className="w-full px-4 py-3 rounded-lg bg-xon-darker border border-xon-border text-white placeholder-xon-muted/50 focus:outline-none focus:border-xon-primary focus:ring-1 focus:ring-xon-primary transition-colors"
                placeholder="you@example.com"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-xon-muted mb-1.5">Password</label>
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                minLength={6}
                className="w-full px-4 py-3 rounded-lg bg-xon-darker border border-xon-border text-white placeholder-xon-muted/50 focus:outline-none focus:border-xon-primary focus:ring-1 focus:ring-xon-primary transition-colors"
                placeholder="At least 6 characters"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-xon-muted mb-1.5">Confirm Password</label>
              <input
                type="password"
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                required
                className="w-full px-4 py-3 rounded-lg bg-xon-darker border border-xon-border text-white placeholder-xon-muted/50 focus:outline-none focus:border-xon-primary focus:ring-1 focus:ring-xon-primary transition-colors"
                placeholder="Re-enter your password"
              />
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full py-3 rounded-lg bg-gradient-to-r from-xon-primary to-orange-600 text-white font-semibold hover:from-xon-primary-hover hover:to-orange-700 transition-all shadow-lg shadow-orange-500/25 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {loading ? 'Creating account...' : 'Create Account'}
            </button>
          </form>

          <p className="text-center text-xon-muted text-sm mt-6">
            Already have an account?{' '}
            <Link to="/login" className="text-xon-primary hover:text-xon-primary-hover font-medium transition-colors">
              Log In
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}
