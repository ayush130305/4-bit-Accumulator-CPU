# edge_pins.py - List frame nets (by label) whose metal reaches the pad ring inner edge; writes JSON.
# Usage: klayout -b -rd gds=<frame.gds> -rd js=<out.json> -r flow/edge_pins.py
# For each labelled net in the frame, list metal shapes touching the inner edge strip of the pad ring.
import pya, json
ly=pya.Layout(); ly.read(gds); top=ly.top_cells()[0]
rsi=pya.RecursiveShapeIterator(ly,top,[])
l2n=pya.LayoutToNetlist(pya.RecursiveShapeIterator(ly,top,[]))
m1=l2n.make_layer(ly.layer(8,0),"m1"); v1=l2n.make_layer(ly.layer(9,0),"v1"); m2=l2n.make_layer(ly.layer(10,0),"m2")
t1=l2n.make_text_layer(ly.layer(8,7),"t1"); t2=l2n.make_text_layer(ly.layer(10,7),"t2")
l2n.connect(m1); l2n.connect(m2); l2n.connect(v1); l2n.connect(m1,v1); l2n.connect(m2,v1)
l2n.connect(m1,t1); l2n.connect(m2,t2)
l2n.extract_netlist()
nl=l2n.netlist(); c=nl.circuit_by_name(top.name)
lo,hi=304.9,2695.1; w=6.0; dbu=ly.dbu
strips={"S":pya.DBox(lo,lo-w,hi,lo+0.01),"N":pya.DBox(lo,hi-0.01,hi,hi+w),"W":pya.DBox(lo-w,lo,lo+0.01,hi),"E":pya.DBox(hi-0.01,lo,hi+w,hi)}
out={}
for net in c.each_net():
    nm=net.name
    if not nm: continue
    for lname,lay in (("m1",m1),("m2",m2)):
        r=l2n.shapes_of_net(net,lay,True)
        for side,sb in strips.items():
            hit=r & pya.Region(sb.to_itype(dbu))
            for p in hit.merged().each():
                b=p.bbox().to_dtype(dbu)
                out.setdefault(nm,[]).append([side,lname,round(b.left,3),round(b.bottom,3),round(b.right,3),round(b.top,3)])
for k in sorted(out): 
    for e in out[k]: print(k,*e)
json.dump(out,open(js,"w"),indent=1)
