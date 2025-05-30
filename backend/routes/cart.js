const express = require('express');
const router = express.Router();
const {
  addToCart,
  getCart,
  removeCartItem,
  clearCart
} = require('../controllers/cartController');

router.post('/', addToCart);
router.get('/:userId', getCart);
router.delete('/item/:itemId', removeCartItem);
router.delete('/:userId', clearCart);

module.exports = router;
