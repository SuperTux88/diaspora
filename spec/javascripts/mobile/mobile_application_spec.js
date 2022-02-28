describe("Diaspora.Mobile", function(){
  describe("initialize", function(){
    beforeEach(function(){
      spec.loadFixture("conversations_new_mobile");
      spyOn(window, "autosize");
    });

    it("calls autosize for textareas", function(){
      Diaspora.Mobile.initialize();
      expect(window.autosize).toHaveBeenCalled();
      expect(window.autosize.calls.mostRecent().args[0].is($("textarea"))).toBe(true);
    });
  });
});
