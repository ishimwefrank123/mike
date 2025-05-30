const Product = require('../models/Product');

exports.addProduct = async (req, res) => {
  try {
    const { name, price, description, category } = req.body;
    const imageUrl = req.file ? `/uploads/${req.file.filename}` : '';
    const product = new Product({ name, price, description, category, imageUrl });
    await product.save();
    res.status(201).json(product);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.getAllProducts = async (req, res) => {
  const products = await Product.find();
  res.json(products);
};

exports.getProductsByCategory = async (req, res) => {
  const products = await Product.find({ category: req.params.cat });
  res.json(products);
};

exports.getProductById = async (req, res) => {
  const product = await Product.findById(req.params.id);
  res.json(product);
};
