const express = require('express');
const router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  const migrations = req.app.locals.migrations;
  res.render('index', { title: 'Evolution Process', migrations: migrations});
});

module.exports = router;