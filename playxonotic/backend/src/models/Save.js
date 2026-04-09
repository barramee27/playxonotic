const mongoose = require('mongoose');

const saveSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true,
    index: true,
  },
  configData: {
    type: Buffer,
    required: true,
  },
  sizeBytes: {
    type: Number,
    default: 0,
  },
  updatedAt: {
    type: Date,
    default: Date.now,
  },
});

saveSchema.pre('save', function () {
  this.updatedAt = new Date();
  if (this.configData) {
    this.sizeBytes = this.configData.length;
  }
});

module.exports = mongoose.model('Save', saveSchema);
