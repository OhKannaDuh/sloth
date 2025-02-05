EmbeddedBrowser = Browser:extend()

function EmbeddedBrowser.default_config()
    return {showdevtools = false, y = 0, x = 0, height = 250, width = 400}
end

function EmbeddedBrowser:open()
    self.browser = self.plugin.bolt.createembeddedbrowser(self.config.x,
                                                          self.config.y,
                                                          self.config.width,
                                                          self.config.height,
                                                          self.config.path,
                                                          self.config.js)

    self:setup()
end

function EmbeddedBrowser:startreposition()
    self.browser:startreposition()
end

function EmbeddedBrowser:cancelreposition()
    self.browser:cancelreposition()
end
