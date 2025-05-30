const express = require('express');
const router = express.Router();
const {
  addMoney,
  getWallet
} = require('../controllers/walletController');

router.post('/add', addMoney);
router.get('/:userId', getWallet);

module.exports = router;
