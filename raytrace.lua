-- title:  Raytrace Demo
-- author: Valink
-- desc:   My implementaion of simple raytracing
-- script: lua

-- TO-DO: 
-- Finish implementing Ray
    -- Head is a Vertex which will collide with Vertexes from the objects

-- Implement Vector - OK		
-- Implement Vertex - OK

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
				
    vert.m = (vert.p2.y-vert.p1.y)/
        (vert.p2.x-vert.p1.x) -- Find slope
    vert.b = -(vert.m*vert.p2.x-vert.p2.y) -- Find y-intercept
    
    function vert:debug()
        return "f(x): "..tostring(l.m).."x + "..tostring(l.b)
    end
    
    function vert:collide(other)
        vert.m = (vert.p2.y-vert.p1.y)/
                (vert.p2.x-vert.p1.x) -- Find slope
        vert.b = -(vert.m*vert.p2.x-vert.p2.y) -- Find y-intercept
        
        local col_point = nil
        if vert.m == math.huge or vert.m == -math.huge then 
            col_point = Vector(vert.p1.x, vert.p1.x * other.m + other.b)
            circ(col_point.x, col_point.y, 1, 5)
        elseif other.m == math.huge or other.m == -math.huge then
            col_point = Vector(other.p1.x, other.p1.x * vert.m + vert.b)
            circ(col_point.x, col_point.y, 1, 6)
        else
            local cx = (other.b-vert.b)/(vert.m-other.m)
            col_point = Vector(cx, other.m * cx+other.b)
            circ(col_point.x, col_point.y, 1, 2)
        end
        
        if ((col_point.x < vert.p1.x and col_point.x > vert.p2.x) or 
            (col_point.x > vert.p1.x and col_point.x < vert.p2.x)) or
           ((col_point.y < vert.p1.y and col_point.y > vert.p2.y) or 
            (col_point.y > vert.p1.y and col_point.y < vert.p2.y)) then
            return col_point
        end
        
    end

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

function Object(verts)
    local obj = {}
    obj.verts = {}

    for i, v in ipairs(verts) do
        table.insert(obj.verts, v)
    end

    function obj:draw(c)
        if c == nil then c = 9 end

        for i, v in ipairs(verts) do
            line(v.p1.x, v.p1.y, v.p2.x, v.p2.y, c)
        end
    end

    function obj:move(movement)
        for i, v in ipairs(verts) do
            v.p1 = v.p1 + movement
            v.p2 = v.p2 + movement
        end
    end

    return obj
end

function Ray(start_point, direction) --represents a ray composed of calculated segments and a "head"
    local ray = {}
    ray.start = start_point --Where the ray will be emitted
    ray.dir = direction --Initial direction in radians of the ray
    
    ray.segments = {  --Every segement of the ray, are all Vectors
        ray.start
    }

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
        ray.segments = {ray.start}
        while true do
            local head = Vertex(
                ray.segments[#ray.segments], -- The last found segment becomes the head
                Vector(math.cos(ray.dir) * 1000, math.sin(ray.dir) * 1000))
            head:draw()
            local collision_counter = 0
            for i, o in ipairs(objects) do 
                for j, v in ipairs(o.verts) do
                    local col_point = v:collide(head)
                    if col_point then 
                        circ(col_point.x, col_point.y, 2, 2) 
                        local v_angle = (v.p2 - v.p1):angle()
                        ray.dir = v_angle - (head.p2-head.p1):angle() + v_angle
                        table.insert(ray.segments, 
                            Vector(col_point.x-head.p1.x, col_point.y-head.p1.y)
                        )
                        collision_counter = collision_counter + 1
                    end
                end
            end
            if collision_counter == 0 then break end -- Continue to cast from previously found collision_points until there's no more collisions
        end
    end
    
    return ray
end

PI = math.pi

r1 = Ray(Vector(0, 0), 0)
o = Object({
    Vertex(Vector(220, 68), Vector(230, 68)),
    --Vertex(Vector(230, 68), Vector(230, 78)),
    --Vertex(Vector(230, 78), Vector(220, 78)),
    --Vertex(Vector(220, 78), Vector(220, 68))
})
o:move(Vector(-50,0))

function TIC()
    mx, my, c = mouse()
    if btn(0) then o:move(Vector(0, -1)) end
    if btn(1) then o:move(Vector(0, 1)) end
    if btn(2) then o:move(Vector(-1, 0)) end
    if btn(3) then o:move(Vector(1, 0)) end

    r1 = Ray(Vector(1, 1), math.atan(my - r1.start.y, mx - r1.start.x))
    cls()
    print(math.atan(my - r1.start.y, mx - r1.start.x))
    o:draw()

    r1:cast({o})
    r1:draw()
end