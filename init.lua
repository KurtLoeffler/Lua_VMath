local modulePrefix = (...) and (...):gsub('%.init$', '').."." or ""
return require(modulePrefix.."VMath")
