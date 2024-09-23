Scaleform = {}

local scaleform = {}
scaleform.__index = scaleform

function Scaleform.Request(Name)
    local ScaleformHandle = RequestScaleformMovie(Name)
    local timer = 1000
    while not HasScaleformMovieLoaded(ScaleformHandle) and timer > 0 do
        timer = timer-1
        Citizen.Wait(0)
    end
    local data = {name = Name, handle = ScaleformHandle}
    return setmetatable(data, scaleform)
end

function scaleform:CallFunction(theFunction, ...)
    BeginScaleformMovieMethod(self.handle, theFunction)
    local arg = { ... }
    if arg ~= nil then
        for i = 1, #arg do
            local sType = type(arg[i])
            if sType == "boolean" then
                ScaleformMovieMethodAddParamBool(arg[i])
            elseif sType == "number" then
                if math.type(arg[i]) == "integer" then
                    ScaleformMovieMethodAddParamInt(arg[i])
                else
                    ScaleformMovieMethodAddParamFloat(arg[i])
                end
            elseif sType == "string" then
				ScaleformMovieMethodAddParamTextureNameString(arg[i])
            end
        end
        EndScaleformMovieMethod()
    end
end

function scaleform:Draw2D()
    DrawScaleformMovieFullscreen(self.handle, 255, 255, 255, 255, 0)
end

function scaleform:Render2DScreenSpace(locx, locy, sizex, sizey)
    local Width, Height = GetScreenResolution()
    local x = locy / Width
    local y = locx / Height
    local width = sizex / Width
    local height = sizey / Height
    DrawScaleformMovie(self.handle, x + (width / 2.0), y + (height / 2.0), width, height, 255, 255, 255, 255, 0)
end

function scaleform:Render3D(pos, rot, scalex, scaley, scalez)
    DrawScaleformMovie_3dSolid(self.handle, pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, 2.0, 2.0, 1.0, scalex, scaley, scalez, 2)
end

function scaleform:Render3DAdditive(pos, rot, scalex, scaley, scalez)
    DrawScaleformMovie_3d(self.handle, pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, 2.0, 2.0, 1.0, scalex, scaley, scalez, 2)
end

function scaleform:Dispose()
    SetScaleformMovieAsNoLongerNeeded(self.handle)
end
