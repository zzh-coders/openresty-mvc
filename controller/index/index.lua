local template = require("resty.template")

template.render("index/index.html", { message = "你好呀" })