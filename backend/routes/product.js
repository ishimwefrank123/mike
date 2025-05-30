const express = require('express');
const router = express.Router();
const upload = require('../middleware/upload');
const {
  addProduct,
  getAllProducts,
  getProductsByCategory,
  getProductById
} = require('../controllers/productController');

router.post('/', upload.single('image'), addProduct);
router.get('/', getAllProducts);
router.get('/:cat', getProductsByCategory);
router.get('/id/:id', getProductById);

module.exports = router;
