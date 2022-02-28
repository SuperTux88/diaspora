describe("Diaspora.Mobile.Drawer", function(){
  describe("initialize", function(){
    beforeEach(function(){
      spec.loadFixture("conversations_new_mobile");
      Diaspora.Mobile.Drawer.initialize();
      this.menuBadge = $("#menu-badge");
      this.followedTags = $("#followed_tags");
      this.allAspects = $("#all_aspects");
    });

    it("correctly binds events", function(){
      expect($._data(this.menuBadge[0], "events").tap.length).not.toBe(0);
      expect($._data(this.menuBadge[0], "events").click.length).not.toBe(0);
    });

    it("opens and closes the drawer", function(){
      var $app = $("#app");
      expect($app).not.toHaveClass("draw");
      this.menuBadge.click();
      expect($app).toHaveClass("draw");
      this.menuBadge.click();
      expect($app).not.toHaveClass("draw");
    });
  });
});
