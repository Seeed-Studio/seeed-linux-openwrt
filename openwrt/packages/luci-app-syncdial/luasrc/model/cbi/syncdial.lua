local e=require"nixio.fs"
require("luci.tools.webadmin")
local e="mwan3 status | grep -c \"is online and tracking is active\""
local e=io.popen(e,"r")
local t=e:read("*a")
e:close()
m=Map("syncdial",translate("Multi-Lan Multicast"),
translate("Using the macvlan to create more WAN,which support the concurrency of Multicast <br />THe number of onLine WAN：")..t)
s=m:section(TypedSection,"syncdial",translate(" "))
s.anonymous=true
o=s:option(Flag,"enabled","Enable")
o.rmempty=false
o=s:option(Flag,"syncon","Enable the Concurrency")
o.rmempty=false
o=s:option(ListValue,"dial_type",translate("The type of Multicast"))
o:value("1",translate("single Lan to Multicast"))
o:value("2",translate("Double Lan to Multicast"))
o.rmempty=false
o=s:option(Value,"wanselect",translate("Choose the Interface"),translate("Choose the Interface to Multicast，such as Wan"))
luci.tools.webadmin.cbi_add_networks(o)
o.optional=false
o.rmempty=false
o=s:option(Value,"wannum","The number of virtual Wan")
o.datatype="range(0,249)"
o.optional=false
o.default=1
o=s:option(Flag,"bindwan","Blinding the Entity Interface")
o.rmempty=false
o=s:option(Value,"wanselect2",translate("choose the second Interface to connect Internet"),translate("<font color=\"red\">choose the second Interface to Multicast，such as wan2</font>"))
luci.tools.webadmin.cbi_add_networks(o)
o.optional=false
o:depends("dial_type","2")
o=s:option(Value,"wannum2",translate("The number of Virtual Wan"),translate("Set the number of second Line"))
o.datatype="range(0,249)"
o.optional=false
o.default=1
o:depends("dial_type","2")
o=s:option(Flag,"bindwan2","Blinding the Entity Interface","Blinding the interface of the Entity Interface and Virtual")
o.rmempty=false
o:depends("dial_type","2")
o=s:option(Flag,"dialchk","Enable the scan of the Outline")
o.rmempty=false
o=s:option(Value,"dialnum","The MIN Number of the online interfaces","It will be reconnect if the online interfaces are less than this number")
o.datatype="range(0,248)"
o.optional=false
o.default=2
o=s:option(Value,"dialnum2","The MIN Number of the online interfaces on second Line","It will be reconnect if the online interfaces are less than this number")
o.datatype="range(0,248)"
o.optional=false
o.default=2
o:depends("dial_type","2")
o=s:option(Value,"dialwait","The waitting Time of reconnect","THe waitting time of reconnect. Unit：second MIn：5second")
o.datatype="and(uinteger,min(5))"
o.optional=false
o=s:option(Flag,"old_frame","Using the old_frame of Macvlan")
o.rmempty=false
o=s:option(Flag,"nomwan","Stop the Auto of the Old MWAN3 configuration","choose your own way to configure MWAN")
o.rmempty=false
o=s:option(DummyValue,"_redial","Reconnect")
o.template="syncdial/redial_button"
o.width="10%"
return m