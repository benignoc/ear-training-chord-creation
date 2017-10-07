math.randomseed(os.time()) -- So as to get different random numbers each time.

local function Msg(param)
  reaper.ShowConsoleMsg(tostring(param).."\n")
end

local function HasValue(tab, val)
  for index, value in ipairs(tab) do
    -- We grab the first index of our sub-table instead
    if value == val then
      return true
    end
  end
  return false
end

local function CreateChord()
  -- Creates a chord in form of array, with as many different random notes 
  -- as m_notes between mn_min and mn_max
  -- Order the chord from lowest to highest (to facilitate later processing)
  chord = {}   -- Array of notes
  for i=1,n_notes,1 do
    m_note = math.random(mn_min, mn_max)
    while HasValue(chord, m_note) do  -- To make sure all notes are different in chord
      m_note = math.random(mn_min, mn_max)
    end
    chord[i] = m_note
  end
  table.sort(chord)
  return(chord)
end



local function InsertMidi4Chord(take, start_pos, time_note, t_between_notes, channel, chord, vel, mode)
  -- Takes a chord (array of midi note values) and creates the midi events in the take selected --
  -- IF Mode == MELODY notes one after the other in the order of the array
  -- Otherwise assume Mode == CHORD all notes at the same time.
  -- Return Nil if no notes were inserted and END TIME (position) otherwise. 
  
  for i, value in ipairs(chord) do
  
    m_ppq_start = reaper.MIDI_GetPPQPosFromProjTime( take, start_pos ) -- i starts at 1
    m_ppq_end =  reaper.MIDI_GetPPQPosFromProjTime( take,  start_pos + time_note )
    note_inserted = reaper.MIDI_InsertNote( take, true, false, m_ppq_start, m_ppq_end, channel, value, vel, false )
    
    t_end = start_pos + time_note
    
    if mode == "MELODY" then
      start_pos = start_pos + time_note + t_between_notes
    end
    
  end
  
  if note_inserted ~= nil then
    return t_end
  else
    return nil
  end

end



local function Main()
  track =  reaper.GetSelectedTrack( 0, 0 ) -- We get the selected track from project (TODO: we assume only one selected)
  pos_init = reaper.GetCursorPosition()
  pos = pos_init
  pos_end = time_note
  item = reaper.CreateNewMIDIItemInProj( track, pos, pos_end ) 
  take = reaper.GetActiveTake( item )
  chord = CreateChord()
  
  -- Add the chord reps times
  for r=0,reps-1,1 do
    t_end = InsertMidi4Chord(take, pos, time_note, silence, m_channel, chord, m_vel, "CHORD")
    pos = t_end + silence
  end

  -- Add the notes of the chord melodically
  t_end = InsertMidi4Chord(take, pos, t_melodic, silence, m_channel, chord, m_vel, "MELODY")
  pos = t_end + silence

  -- Add the chord one last time
  t_end = InsertMidi4Chord(take, pos, time_note, silence, m_channel, chord, m_vel, "CHORD")
  
  reaper.MIDI_Sort( take )
  
  name = n_notes.."n"
  octaves = math.floor((mn_max - mn_min) / 12)
  name = name..octaves.."o"
  for  i, note in ipairs(chord) do
    if note % 12 == 0 then name = name.."_C"
    elseif note % 12 == 1 then name = name.."_C#"
    elseif note % 12 == 2 then name = name.."_D"
    elseif note % 12 == 3 then name = name.."_D#"
    elseif note % 12 == 4 then name = name.."_E"
    elseif note % 12 == 5 then name = name.."_F"
    elseif note % 12 == 6 then name = name.."_F#"
    elseif note % 12 == 7 then name = name.."_G"
    elseif note % 12 == 8 then name = name.."_G#"
    elseif note % 12 == 9 then name = name.."_A"
    elseif note % 12 == 10 then name = name.."_A#"
    elseif note % 12 == 11 then name = name.."_B"
    end
  end
  i_modified = reaper.BR_SetItemEdges( item, pos_init, t_end )
  retval, stringNeedBig = reaper.GetSetMediaItemTakeInfo_String( take, "P_NAME", name, true )
  -- Set cursor at the end of the midi element
  --reaper.MoveEditCursor( pos_end, false )
  reaper.SetEditCurPos( t_end + extra_sp, true, true )
  reaper.UpdateArrange() 
end

local dm, _ = debug_mode
local function Msg(str)
  reaper.ShowConsoleMsg(tostring(str).."\n")
end



local info = debug.getinfo(1,'S');
script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]

-- I hate working with 'requires', so I've opted to do it this way.
-- This also works much more easily with my Script Compiler.
local function req(file)
  
  if missing_lib then return function () end end
  
  local ret, err = loadfile(script_path .. file)
  if not ret then
    reaper.ShowMessageBox("Couldn't load "..file.."\n\nError: "..tostring(err), "Library error", 0)
    missing_lib = true    
    return function () end

  else 
    return ret
  end  

end


-- The Core library must be loaded prior to any classes, or the classes will throw up errors
-- when they look for functions that aren't there.
req("Core.lua")()

-- For better cross-platform behavior.
local sep = GUI.file_sep

req("Classes"..sep.."Class - Label.lua")()
req("Classes"..sep.."Class - Knob.lua")()
--req("Classes"..sep.."Class - Tabs.lua")()
req("Classes"..sep.."Class - Slider.lua")()
req("Classes"..sep.."Class - Button.lua")()
--req("Classes"..sep.."Class - Menubox.lua")()
--req("Classes"..sep.."Class - Checklist.lua")()
--req("Classes"..sep.."Class - Radio.lua")()
--req("Classes"..sep.."Class - Textbox.lua")()
--req("Classes"..sep.."Class - Frame.lua")()

-- If any of the requested libraries weren't found, abort the script.
if missing_lib then return 0 end


GUI.name = "BCA Ear Training - Training Chords Creator"
GUI.x, GUI.y, GUI.w, GUI.h = 0, 0, 350, 300
GUI.anchor, GUI.corner = "mouse", "C"

--[[  
  New elements are created by:
  
  GUI.New(name, class, params)
  
  and can then have their parameters accessed via:
  
  GUI.elms.name.param
  
  ex:
  
  GUI.New("my_new_label", "Label", 1, 32, 32, "This is my label")
  GUI.elms.my_new_label.color = "magenta"
  GUI.elms.my_new_label.font = 1
  
  
    Classes and parameters
  
  Button    name,   z,   x,   y,   w,   h, caption, func[, ...]
  Checklist  name,   z,   x,   y,   w,   h, caption, opts[, dir, pad]
  Frame    name,   z,   x,   y,   w,   h[, shadow, fill, color, round]
  Knob    name,   z,   x,   y,   w,   caption, min, max, steps, default[, vals]  
  Label    name,   z,   x,   y,    caption[, shadow, font, color, bg]
  Menubox    name,   z,   x,   y,   w,   h, caption, opts
  Radio    name,   z,   x,   y,   w,   h, caption, opts[, dir, pad]
  Slider    name,   z,   x,   y,   w,   caption, min, max, steps, handles[, dir]
  Tabs    name,   z,   x,   y,     tab_w, tab_h, opts[, pad]
  Textbox    name,   z,   x,   y,   w,   h[, caption, pad]
  
]]--

local function btn_click()

   m_channel = 1  -- Midi channel
   m_vel = 100    -- Midi Velocity
   extra_sp = 1   -- Space between item takes
   reps = GUI.Val("reps")
   --n_notes = GUI.elms.n_notes.curstep
   n_notes = GUI.Val("n_notes")
   mn_min =  GUI.Val("start_note")
   mn_max =  GUI.Val("end_note")
   time_note =  GUI.Val("time_note")/10
   t_melodic =  GUI.Val("t_melodic")/10
   silence =  GUI.Val("silence")/10
  
  Main()

end

GUI.New("my_label", "Label", 1, 10, 250, "Ear Training Exercise Maker")
GUI.elms.my_label.color = "white"
GUI.elms.my_label.font = 2
GUI.New("my_new_label", "Label", 1, 10, 270, "www.benignocalvo.com")
GUI.elms.my_new_label.color = "white"
GUI.elms.my_new_label.font = 3
GUI.New("n_notes",  "Knob",    1,  50, 50, 40, "Notes", 1,10,10,2,1)
GUI.New("start_note", "Slider", 1, 180, 45, 150, "From Note (48 = C3)", 1, 128, 127, 0)
GUI.New("end_note", "Slider", 1, 180, 100, 150, "To Note (72 = C5)", 1, 128, 127, 128)
GUI.New("time_note",  "Slider",    1, 10, 155, 150, "Chord Time (in ds)", 1, 100, 99, 0 )
GUI.New("t_melodic",  "Slider",    1, 180, 155, 150, "Melodic Time (in ds)", 1, 100, 99, 0 )
GUI.New("silence",  "Slider",    1, 10, 210, 150, "Silence Between (Time in ds)", 0, 30, 30, 0 )
GUI.New("reps",  "Slider",    1, 180, 210, 150, "Repeats", 1, 5, 4, 0 )
GUI.New("btn_go",  "Button",    1, 220, 250, 64, 24, "Go!", btn_click)

--GUI.New("chk_opts",  "Checklist",  1, 192,  32,  192, 96, "Options", "Only in time selection,Only on selected track,Glue items when finished", "v", 4)
--GUI.New("sldr_thresh", "Slider",  1, 32,  96, 128, "Threshold", -500, 0, 500, 482, "h")
--GUI.New("btn_go",  "Button",    1, 168, 152, 64, 24, "Go!", btn_click)

reaper.ShowConsoleMsg("") -- To Initialise the msg screen

GUI.Init()
GUI.Main()

