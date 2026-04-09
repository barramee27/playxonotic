const express = require('express');
const Save = require('../models/Save');
const auth = require('../middleware/auth');

const router = express.Router();

const MAX_SAVE_SIZE = 5 * 1024 * 1024; // 5 MB

// GET /api/save -- retrieve the user's cloud save
router.get('/', auth, async (req, res) => {
  try {
    const save = await Save.findOne({ userId: req.user._id });
    if (!save) {
      return res.status(404).json({ error: 'No save data found' });
    }
    res.json({
      updatedAt: save.updatedAt,
      sizeBytes: save.sizeBytes,
      configData: save.configData.toString('base64'),
    });
  } catch (err) {
    console.error('Get save error:', err);
    res.status(500).json({ error: 'Server error' });
  }
});

// POST /api/save -- upload/overwrite the user's cloud save
router.post('/', auth, async (req, res) => {
  try {
    const { configData } = req.body;

    if (!configData) {
      return res.status(400).json({ error: 'configData is required (base64 encoded)' });
    }

    const buf = Buffer.from(configData, 'base64');

    if (buf.length > MAX_SAVE_SIZE) {
      return res.status(413).json({ error: 'Save data exceeds 5 MB limit' });
    }

    const save = await Save.findOneAndUpdate(
      { userId: req.user._id },
      { configData: buf, sizeBytes: buf.length, updatedAt: new Date() },
      { upsert: true, new: true }
    );

    res.json({
      message: 'Save uploaded successfully',
      updatedAt: save.updatedAt,
      sizeBytes: save.sizeBytes,
    });
  } catch (err) {
    console.error('Post save error:', err);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
