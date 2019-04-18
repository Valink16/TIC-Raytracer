-- title:  Raytrace Demo
-- author: Valink
-- desc:   My implementaion of simple raytracing
-- script: lua

-- TO-DO: 
-- Finish implementing Ray
    -- Head is a Line which will collide with Vertex's Line

-- Implement Vector - OK		
-- Implement Vertex - OK
-- Implement Line - OK

-- Implement Object(collection of Vertex)

function Vector(x, y) --Can represent a point or a vector
    local vec = {}
    vec.x = x 
    vec.y = y
    
    function vec:draw(c) 
        if c == nil then c = 2 end
        pix(vec.x, vec.y, c)
    end
                
    function vec:normalized()
        return vec / #vec
    end

    function vec:dot_prod(other)
        return vec.x*other.x + vec.y*other.y
    end

    function vec:angle_with(other)
        -- Calculates angle between the 2 Vectors using dot product (ax * bx + ay * by) 
        return math.acos(vec:normalized():dot_prod(other:normalized()))
    end

    function vec:angle()
        -- Calculates angle
        return math.atan(vec.y, vec.x)
    end

    local mt = {
        __add=function(self, other)
            return Vector(self.x+other.x, self.y+other.y)
        end,
        __sub=function(self, other)
            return Vector(self.x-other.x, self.y-other.y)
        end,
        __mul=function(self, multiplier)
            return Vector(self.x*multiplier, self.y*multiplier)
        end,
        __div=function(self, divider)
            return Vector(self.x/divider, self.y/divider)
        end,
        __len=function(self)
            return math.sqrt(
                self.x*self.x+
                self.y*self.y
            )
        end
    }
    setmetatable(vec, mt)
    return vec
end

function Vertex(p1, p2) --Two vectors forming a line
    local vert = {}
    vert.p1 = p1
    vert.p2 = p2
    vert.m = 0
    vert.b = 0

    function vert:draw(c)
        --For debug purpose only, use Object's draw method
        if c == nil then c = 1 end
        line(vert.p1.x, vert.p1.y, vert.p2.x, vert.p2.y, c)
    end
    
    local mt = {
        __len=function(self)
            return #(self.p1-self.p2)
        end
    }
    setmetatable(vert, mt)
    return vert
end

function Line(vert)
    -- Represents a vertex as mx + b to help with line to line collisions
    local l = {}
    l.pos = vert.p1
    l.m = (vert.p2.y-vert.p1.y)/
        (vert.p2.x-vert.p1.x) -- Find slope
    l.b = -(l.m*vert.p2.x-vert.p2.y) -- Find y-intercept
    
    function l:debug()
        return "f(x): "..tostring(l.m).."x + "..tostring(l.b)
    end

    function l:draw(c)
        if c == nil then c = 4 end
        line(-1, l.m * x + l.b, 241, l.m * 241 + l.b, c)
    end
    
    function l:collide(other)
        --if l.m == math.huge then -- If self is a vertical line
        --    return Vector()
        --end
        local cx = (l.b-other.b)/(other.m-l.m)
        return Vector(cx, l.m*cx+l.b)
    end
    
    return l
end

function Object(verts)
    local obj = {}
    obj.verts = {}

    for i, v in ipairs(verts) do
        table.insert(obj.verts, v)
    end

    trace("Object's vertexes : "..tostring(#obj.verts))

    function obj:draw(c)
        if c == nil then c = 9 end

        for i, v in ipairs(verts) do
            line(v.p1.x, v.p1.y, v.p2.x, v.p2.y, c)
        end
    end

    return obj
end

function Ray(start_point, direction) --represents a ray composed of calculated segments and a "head"
    local ray = {}
    ray.start = start_point --Where the ray will be emitted
    ray.dir = direction --Initial direction in radians of the ray
    
    ray.segments = {} --Every segement of the ray, are all Vectors

    function ray:draw(c)
        if c == nil then c = 14 end
        
        local sx = ray.start.x
        local sy = ray.start.y
        for i, s in ipairs(ray.segments) do
            line(sx, sy, sx+s.x, sy+s.y, c)
            circ(sx, sy, 1, 2)
            sx = sx+s.x
            sy = sy+s.y
        end
    end
    
    function ray:cast(objects) --Casts the "head" and creates segment if a collision occurs
        local head = Vertex(
            Vector(ray.start.x, ray.start.y),
            Vector(math.cos(ray.dir) * 1000, math.sin(ray.dir) * 1000))
        head:draw()
        trace(head.p2.x)
        trace(head.p2.y)
        local head_line = Line(head)
        for i, o in ipairs(objects) do 
            for j, v in ipairs(o.verts) do
                local col_point = Line(v):collide(head_line)
                circ(col_point.x, col_point.y, 2, 2)
            end
        end
    end
    
    return ray
end

PI = math.pi

r1 = Ray(Vector(0, 68), 0)
o = Object({
    Vertex(Vector(220, 68), Vector(228, 68)),
    Vertex(Vector(228, 68), Vector(232, 78)),
    Vertex(Vector(232, 78), Vector(222, 78)),
    Vertex(Vector(222, 78), Vector(220, 68))
})

function TIC()
    mx, my, c = mouse()

    if c then r1 = Ray(Vector(120, 68), math.atan(my-68, mx-120)) end
    cls()
    print(math.atan(my-68, mx-120))
    r1:cast({o})
    r1:draw()
    o:draw()
end