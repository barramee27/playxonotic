const express = require('express');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const auth = require('../middleware/auth');

const router = express.Router();

const generateToken = (userId) => {
  return jwt.sign({ userId }, process.env.JWT_SECRET, { expiresIn: '7d' });
};

// POST /api/auth/signup
router.post('/signup', async (req, res) => {
  try {
    const { username, email, password } = req.body;

    if (!username || !email || !password) {
      return res.status(400).json({ error: 'Username, email, and password are required' });
    }

    if (password.length < 6) {
      return res.status(400).json({ error: 'Password must be at least 6 characters' });
    }

    const existingUser = await User.findOne({ $or: [{ email }, { username }] });
    if (existingUser) {
      if (existingUser.email === email) {
        return res.status(400).json({ error: 'Email already registered' });
      }
      return res.status(400).json({ error: 'Username already taken' });
    }

    const user = new User({ username, email, passwordHash: password });
    await user.save();

    const token = generateToken(user._id);

    res.status(201).json({
      message: 'Account created successfully',
      token,
      user: user.toPublicJSON(),
    });
  } catch (err) {
    if (err.name === 'ValidationError') {
      const messages = Object.values(err.errors).map((e) => e.message);
      return res.status(400).json({ error: messages[0] });
    }
    console.error('Signup error:', err);
    res.status(500).json({ error: 'Server error' });
  }
});

// POST /api/auth/login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    const user = await User.findOne({ email: email.toLowerCase() });
    if (!user) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    user.lastLogin = new Date();
    await user.save();

    const token = generateToken(user._id);

    res.json({
      message: 'Login successful',
      token,
      user: user.toPublicJSON(),
    });
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({ error: 'Server error' });
  }
});

// GET /api/auth/me
router.get('/me', auth, async (req, res) => {
  res.json({ user: req.user.toPublicJSON() });
});

// POST /api/auth/increment-games
router.post('/increment-games', auth, async (req, res) => {
  try {
    const user = req.user;
    user.gamesPlayed = (user.gamesPlayed || 0) + 1;
    await user.save();
    
    // Get the highest games played ever across all users
    const highestEver = await User.findOne().sort('-gamesPlayed').select('gamesPlayed').lean();
    const highestGamesPlayed = highestEver ? highestEver.gamesPlayed : 0;
    
    res.json({
      gamesPlayed: user.gamesPlayed,
      highestEver: highestGamesPlayed,
    });
  } catch (err) {
    console.error('Increment games error:', err);
    res.status(500).json({ error: 'Server error' });
  }
});

// GET /api/auth/stats
router.get('/stats', auth, async (req, res) => {
  try {
    // Get the highest games played ever across all users
    const highestEver = await User.findOne().sort('-gamesPlayed').select('gamesPlayed').lean();
    const highestGamesPlayed = highestEver ? highestEver.gamesPlayed : 0;
    
    res.json({
      highestEver: highestGamesPlayed,
    });
  } catch (err) {
    console.error('Stats error:', err);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
