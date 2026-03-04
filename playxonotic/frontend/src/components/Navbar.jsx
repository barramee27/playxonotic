import { Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export default function Navbar() {
  const { user, logout } = useAuth();

  return (
    <nav className="fixed top-0 left-0 right-0 z-50 bg-xon-darker/80 backdrop-blur-md border-b border-xon-border">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          <Link to="/" className="flex items-center gap-2 group">
            <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-xon-primary to-orange-600 flex items-center justify-center font-bold text-white text-sm">
              X
            </div>
            <span className="text-xl font-bold text-white group-hover:text-xon-primary transition-colors">
              PlayXonotic
            </span>
          </Link>

          <div className="flex items-center gap-4">
            {user ? (
              <>
                <span className="text-xon-muted text-sm hidden sm:block">
                  Welcome, <span className="text-xon-accent font-medium">{user.username}</span>
                </span>
                <Link
                  to="/play"
                  className="px-5 py-2 rounded-lg bg-gradient-to-r from-xon-primary to-orange-600 text-white font-semibold hover:from-xon-primary-hover hover:to-orange-700 transition-all shadow-lg shadow-orange-500/25"
                >
                  Play Now
                </Link>
                <button
                  onClick={logout}
                  className="px-3 py-2 text-sm text-xon-muted hover:text-white transition-colors"
                >
                  Logout
                </button>
              </>
            ) : (
              <>
                <Link
                  to="/login"
                  className="px-4 py-2 text-sm text-xon-muted hover:text-white transition-colors"
                >
                  Log In
                </Link>
                <Link
                  to="/signup"
                  className="px-5 py-2 rounded-lg bg-gradient-to-r from-xon-primary to-orange-600 text-white font-semibold hover:from-xon-primary-hover hover:to-orange-700 transition-all shadow-lg shadow-orange-500/25"
                >
                  Sign Up
                </Link>
              </>
            )}
          </div>
        </div>
      </div>
    </nav>
  );
}
