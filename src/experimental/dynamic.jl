using MsgPack
open("hello.msg", "w") do f
    t = (a=0, b=0, c=1)
    pack(f, t)
end
