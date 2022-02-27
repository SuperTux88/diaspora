// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.pages.Profile = app.views.Base.extend({
  templateName: false,

  events: {
    "click #block_user_button": "blockPerson",
    "click #unblock_user_button": "unblockPerson"
  },

  subviews: {
    "#profile": "sidebarView",
    ".profile_header": "headerView",
  },

  tooltipSelector: ".profile_button .profile-header-icon, .sharing_message_container",

  initialize: function(opts) {
    if( !this.model ) {
      this._populateModel(opts);
    }

    if (app.hasPreload("photos_count")) {
      this.photos = app.parsePreload("photos_count");
    }

    this.model.on("sync", this._done, this);

    // bind to global events
    var id = this.model.get("id");
    app.events.on("person:block:"+id, this.reload, this);
    app.events.on("person:unblock:"+id, this.reload, this);
    app.events.on("aspect:create", this.reload, this);
    app.events.on("aspect_membership:update", this.reload, this);

    app.router.renderAspectMembershipDropdowns(this.$el);
  },

  _populateModel: function(opts) {
    if( app.hasPreload("person") ) {
      this.model = new app.models.Person(app.parsePreload("person"));
    } else if(opts && opts.person_id) {
      this.model = new app.models.Person({guid: opts.person_id});
      this.model.fetch();
    } else {
      throw new Error("unable to load person");
    }
  },

  sidebarView: function() {
    if(!this.model.has("profile")){
      return false;
    }
    return new app.views.ProfileSidebar({
      model: this.model
    });
  },

  headerView: function() {
    if(!this.model.has("profile")){
      return false;
    }
    return new app.views.ProfileHeader({
      model: this.model,
      photos: this.photos,
    });
  },

  blockPerson: function() {
    if(!confirm(Diaspora.I18n.t("ignore_user"))){
      return;
    }

    var block = this.model.block();
    block.fail(function() {
      app.flashMessages.error(Diaspora.I18n.t("ignore_failed"));
    });

    return false;
  },

  unblockPerson: function() {
    var block = this.model.unblock();
    block.fail(function() {
      app.flashMessages.error(Diaspora.I18.t("unblock_failed"));
    });
    return false;
  },

  reload: function() {
    this.$("#profile").addClass("loading");
    this.model.fetch();
  },

  _done: function() {
    this.$("#profile").removeClass("loading");
  }
});
// @license-end
