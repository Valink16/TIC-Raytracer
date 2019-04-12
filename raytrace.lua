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

-- Implement Object(collection of Vertex, basically an obb)

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

    function vec:angle(other)
        -- Calculates angle between the 2 Vectors using dot product (ax * bx + ay * by) 
        return math.acos(vec:normalized():dot_prod(other:normalized()))
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
    local l = {}
    l.m = (vert.p2.y-vert.p1.y)/
        (vert.p2.x-vert.p1.x)
    l.b = -(l.m*vert.p2.x-vert.p2.y)
    
    function l:debug()
        return "f(x): "..tostring(l.m).."x + "..tostring(l.b)
    end
    
    function l:collide(other)
        local cx = (l.b-other.b)/(other.m-l.m)
        return Vector(cx, l.m*cx+l.b)
    end
    
    return l
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
    
    function cast_ray(objects) --Casts the "head" and creates segments if a collision occurs
        
    end
    
    return ray
end

PI = math.pi

v1 = Vertex(
    Vector(0, 0), Vector(240, 136)
)

v2 = Vertex(
    Vector(240, 0), Vector(0, 136)
)

r1 = Ray(Vector(0, 0), 7*PI/4)

for i=0, 10, 1 do
    table.insert(r1.segments, Vector(math.random(20, 50), math.random(20, 50)))
end

function TIC()
    cls()
    mx, my, c = mouse()
    if c then v1.p2 = Vector(mx, my) end
    v1.draw()
    v2.draw()
    
    l1 = Line(v1)
    l2 = Line(v2)

    tmp_v1 = v1.p2-v1.p1
    tmp_v2 = v2.p2-v2.p1
    a = tmp_v1:angle(tmp_v2)
    print(a)

    v2_angle = math.atan(tmp_v2.y, tmp_v2.x)
    print(v2_angle, 0, 8)
    target_a = v2_angle + (v2_angle - a)
    print(target_a, 0, 16)
    bounce_v = Vector(
        math.cos(target_a),
        math.sin(target_a)
    )

    r1.draw()

    collide_point = l1:collide(l2)
    circ(collide_point.x, collide_point.y, 2, 2)
    line(collide_point.x, collide_point.y, bounce_v.x, bounce_v.y, 2)
end