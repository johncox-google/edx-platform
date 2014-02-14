define ["jquery", "coffee/src/views/module_edit", "js/models/module_info", "xmodule"], ($, ModuleEdit, ModuleModel) ->

    describe "ModuleEdit", ->
      beforeEach ->
        @stubModule = new ModuleModel
            id: "stub-id"

        setFixtures """
        <li class="component" id="stub-id">
          <div class="component-editor">
            <div class="module-editor">
              ${editor}
            </div>
            <a href="#" class="save-button">Save</a>
            <a href="#" class="cancel-button">Cancel</a>
          </div>
          <div class="component-actions">
            <a href="#" class="edit-button"><span class="edit-icon white"></span>Edit</a>
            <a href="#" class="delete-button"><span class="delete-icon white"></span>Delete</a>
          </div>
          <span class="drag-handle"></span>
          <section class="xblock xblock-student_view xmodule_display xmodule_stub" data-type="StubModule">
            <div id="stub-module-content"/>
          </section>
        </li>
        """
        spyOn($, 'ajax').andReturn(@moduleData)

        @moduleEdit = new ModuleEdit(
          el: $(".component")
          model: @stubModule
          onDelete: jasmine.createSpy()
        )

      describe "class definition", ->
        it "sets the correct tagName", ->
          expect(@moduleEdit.tagName).toEqual("li")

        it "sets the correct className", ->
          expect(@moduleEdit.className).toEqual("component")

      describe "methods", ->
        describe "initialize", ->
          beforeEach ->
            spyOn(ModuleEdit.prototype, 'render')
            @moduleEdit = new ModuleEdit(
              el: $(".component")
              model: @stubModule
              onDelete: jasmine.createSpy()
            )

          it "renders the module editor", ->
            expect(ModuleEdit.prototype.render).toHaveBeenCalled()

        describe "render", ->
          beforeEach ->
            spyOn(@moduleEdit, 'initializeXBlock')
            spyOn(@moduleEdit, 'delegateEvents')
            spyOn($.fn, 'append')
            spyOn($, 'getScript')

            window.loadedXBlockResources = undefined

            @moduleEdit.render()
            $.ajax.mostRecentCall.args[0].success(
              html: '<div>Response html</div>'
              resources: [
                ['hash1', {kind: 'text', mimetype: 'text/css', data: 'inline-css'}],
                ['hash2', {kind: 'url', mimetype: 'text/css', data: 'css-url'}],
                ['hash3', {kind: 'text', mimetype: 'application/javascript', data: 'inline-js'}],
                ['hash4', {kind: 'url', mimetype: 'application/javascript', data: 'js-url'}],
                ['hash5', {placement: 'head', mimetype: 'text/html', data: 'head-html'}],
                ['hash6', {placement: 'not-head', mimetype: 'text/html', data: 'not-head-html'}],
              ]
            )

          it "loads the module preview and editor via ajax on the view element", ->
            expect($.ajax).toHaveBeenCalledWith(
              url: "/xblock/#{@moduleEdit.model.id}"
              type: "GET"
              headers:
                Accept: 'application/x-fragment+json'
              success: jasmine.any(Function)
            )
            expect(@moduleEdit.initializeXBlock).toHaveBeenCalled()
            expect(@moduleEdit.delegateEvents).toHaveBeenCalled()

          it "loads inline css from fragments", ->
            expect($('head').append).toHaveBeenCalledWith("<style type='text/css'>inline-css</style>")

          it "loads css urls from fragments", ->
            expect($('head').append).toHaveBeenCalledWith("<link rel='stylesheet' href='css-url' type='text/css'>")

          it "loads inline js from fragments", ->
            expect($('head').append).toHaveBeenCalledWith("<script>inline-js</script>")

          it "loads js urls from fragments", ->
            expect($.getScript).toHaveBeenCalledWith("js-url")

          it "loads head html", ->
            expect($('head').append).toHaveBeenCalledWith("head-html")

          it "doesn't load body html", ->
            expect($.fn.append).not.toHaveBeenCalledWith('not-head-html')

          it "doesn't reload resources", ->
            count = $('head').append.callCount
            $.ajax.mostRecentCall.args[0].success(
              html: '<div>Response html 2</div>'
              resources: [
                ['hash1', {kind: 'text', mimetype: 'text/css', data: 'inline-css'}],
              ]
            )
            expect($('head').append.callCount).toBe(count)
