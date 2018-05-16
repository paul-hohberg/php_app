class php_app::deploy {
  class{'php_app::offline': }->
  class{'php_app::site': }
}
