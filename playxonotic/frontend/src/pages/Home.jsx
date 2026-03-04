import { Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

function FeatureCard({ title, description, icon }) {
  return (
    <div className="bg-xon-card border border-xon-border rounded-xl p-6 hover:border-xon-primary/50 transition-all group">
      <div className="text-3xl mb-4">{icon}</div>
      <h3 className="text-lg font-semibold text-white mb-2 group-hover:text-xon-primary transition-colors">
        {title}
      </h3>
      <p className="text-xon-muted text-sm leading-relaxed">{description}</p>
    </div>
  );
}

export default function Home() {
  const { user } = useAuth();

  return (
    <div className="min-h-screen">
      {/* Hero */}
      <section className="relative pt-32 pb-20 px-4 overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-b from-xon-primary/5 via-transparent to-transparent" />
        <div className="absolute top-20 left-1/2 -translate-x-1/2 w-[600px] h-[600px] bg-xon-primary/10 rounded-full blur-[128px] pointer-events-none" />

        <div className="relative max-w-4xl mx-auto text-center">
          <div className="inline-block px-4 py-1.5 rounded-full bg-xon-primary/10 border border-xon-primary/20 text-xon-primary text-sm font-medium mb-6">
            Free-to-play Arena Shooter
          </div>

          <h1 className="text-5xl sm:text-6xl lg:text-7xl font-extrabold text-white mb-6 leading-tight">
            Play{' '}
            <span className="bg-gradient-to-r from-xon-primary to-orange-400 bg-clip-text text-transparent">
              Xonotic
            </span>
            <br />
            In Your Browser
          </h1>

          <p className="text-lg sm:text-xl text-xon-muted max-w-2xl mx-auto mb-10 leading-relaxed">
            The legendary open-source arena shooter, now playable directly in your web browser.
            No downloads. No installs. Just pure fast-paced action.
          </p>

          <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
            {user ? (
              <Link
                to="/play"
                className="px-8 py-4 rounded-xl bg-gradient-to-r from-xon-primary to-orange-600 text-white text-lg font-bold hover:from-xon-primary-hover hover:to-orange-700 transition-all shadow-2xl shadow-orange-500/30 hover:shadow-orange-500/50 hover:scale-105"
              >
                Launch Game
              </Link>
            ) : (
              <>
                <Link
                  to="/signup"
                  className="px-8 py-4 rounded-xl bg-gradient-to-r from-xon-primary to-orange-600 text-white text-lg font-bold hover:from-xon-primary-hover hover:to-orange-700 transition-all shadow-2xl shadow-orange-500/30 hover:shadow-orange-500/50 hover:scale-105"
                >
                  Create Account
                </Link>
                <Link
                  to="/login"
                  className="px-8 py-4 rounded-xl border border-xon-border text-white text-lg font-semibold hover:bg-xon-card hover:border-xon-muted transition-all"
                >
                  Log In
                </Link>
              </>
            )}
          </div>
        </div>
      </section>

      {/* Features */}
      <section className="py-20 px-4">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-3xl font-bold text-white text-center mb-12">
            Why Play on <span className="text-xon-primary">PlayXonotic</span>?
          </h2>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <FeatureCard
              icon="🎮"
              title="Instant Play"
              description="No downloads or installs required. Open your browser and jump straight into the action."
            />
            <FeatureCard
              icon="⚡"
              title="Fast-Paced Combat"
              description="Experience the full Xonotic arena shooter with all weapons, maps, and game modes."
            />
            <FeatureCard
              icon="🌐"
              title="Cross-Platform"
              description="Play on any device with a modern web browser. Desktop, laptop, or tablet."
            />
            <FeatureCard
              icon="🤖"
              title="Play vs Bots"
              description="Practice your skills against AI opponents in single-player mode."
            />
            <FeatureCard
              icon="🏆"
              title="Multiplayer"
              description="Join matches with other players on our dedicated servers."
            />
            <FeatureCard
              icon="🔓"
              title="100% Free"
              description="Xonotic is open-source and completely free. No pay-to-win, no ads."
            />
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="border-t border-xon-border py-8 px-4">
        <div className="max-w-6xl mx-auto flex flex-col items-center gap-2">
          <p className="text-xon-muted text-sm">
            PlayXonotic &mdash; Powered by DarkPlaces Engine & WebAssembly
          </p>
          <p className="text-xon-muted text-sm">
            Created by Barramee Kottanawadee
          </p>
          <p className="text-xon-muted text-xs">
            <a href="https://xonotic.org" target="_blank" rel="noopener" className="hover:text-xon-primary transition-colors">
              Xonotic.org
            </a>
          </p>
        </div>
      </footer>
    </div>
  );
}
