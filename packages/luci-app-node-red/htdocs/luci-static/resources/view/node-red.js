'use strict';
'require view';
'require form';
'require uci';
'require fs';


return view.extend({

    handleToggleNodeRED: function () {
    },

    handleOpenWeb: function () {
        var port = uci.get('node-red', 'common', 'port');
        window.open('//'+window.location.hostname+':' + port);
    },


    load: function () {

        return Promise.all([
            uci.load('node-red'),
            fs.exec("/usr/libexec/node-red-ctrl", ['--state'])
        ]);
    },

    render: function (data) {


        var state = data[1];


        var m = new form.Map('node-red', _('Node RED'), _('Node Red'));

        var s = m.section(form.NamedSection, 'common', _('Status'));

        var o = s.option(form.Button, 'status', _('status'));


        if (state["stdout"] === "node-red started...\n") {
            o.inputtitle = _('Open Web Interface');
            o.inputstyle = 'apply';
            o.onclick = L.bind(this.handleOpenWeb, this, m);
        } else {
            o.inputtitle = _('Please start the node red service first');
            o.inputstyle = 'reset';
            o.onclick = L.bind(this.handleToggleNodeRED, this, m);
        }


        return m.render();

    }

});