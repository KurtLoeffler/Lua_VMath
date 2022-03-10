local modulePrefix = (...) and (...):gsub('%.init$', '').."." or ""

-- linter like this
if false then
	return require("VMath")
end

return require(modulePrefix.."VMath")
