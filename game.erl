-module(game).

-include_lib("wx/include/wx.hrl").
-define(max_x, (1200)).
-define(max_y, (500)).
-define(toRadian, math:pi()/180).

-compile(export_all).


play()->
    register(graphicServer, spawn( fun()-> start() end)).


%% Create the window.
start() ->
    Wx = wx:new(),
    Frame = wxFrame:new(Wx, -1, "Main Game Frame", [{size, {?max_x, ?max_y}}]),
    
    MenuBar = wxMenuBar:new(),
    wxFrame:setMenuBar(Frame, MenuBar),
    FileMn = wxMenu:new(),
    wxMenuBar:append(MenuBar, FileMn, "&File"),
    Start = wxMenuItem:new([{id, 300}, {text, "&Start"}]),
    wxMenu:append(FileMn, Start),
    Quit = wxMenuItem:new([{id, 400}, {text, "&Quit"}]),
    wxMenu:append(FileMn, Quit),
    
    wxFrame:connect(Frame, command_menu_selected),
    wxFrame:connect(Frame, close_window),
    
    Panel = wxPanel:new(Frame),
    wxFrame:connect(Panel, paint),
	
    wxFrame:show(Frame),

    loop(Frame, Panel).



loop(Frame, Panel) ->
    receive 
	{add, spaceship, Pos}->
	    addSpaceship(Panel, Pos),
%	    timer:sleep(3000),
%	    NewPanel=clearScreen(Frame, Panel),
%	    loop(Frame, NewPanel);
	    loop(Frame, Panel);

	{wx, _, _, _, {wxPaint, paint}} ->
		
	    loop(Frame, Panel);
				
	{wx, _, _, _, {wxClose,close_window}} ->
			wxFrame:destroy(Frame);
	
	{wx, ID, A, B, C} ->
	    case ID of
		300 ->
		    addSpaceship(Panel, {?max_x div 2, ?max_y div 2}),
		    timer:sleep(3000),
		    NewPanel=clearScreen(Frame, Panel),
		    loop(Frame, NewPanel);
%		    loop(Frame, Panel);
		400 ->
		    wxFrame:destroy(Frame);			
		ID ->
		    io:fwrite("In case:~n {~p,~p,~p,~p,~p}~n",[wx,ID,A,B,C]),
		    loop(Frame, Panel)
	    end;
			
		What ->
			io:fwrite("~p~n",[What]),
			loop(Frame, Panel)
	end.
			
addSpaceship(Panel, Pos) ->
    Image = wxImage:new(),
    wxImage:loadFile(Image, "spaceship.png"),
    ClientDC = wxClientDC:new(Panel),
    Bitmap = wxBitmap:new(Image),
    wxDC:drawBitmap(ClientDC, Bitmap, Pos),
    wxBitmap:destroy(Bitmap),
    wxImage:destroy(Image),
    wxClientDC:destroy(ClientDC).

	
clearScreen(Frame, Panel)->
    wxFrame:disconnect(Panel, paint),
    wxPanel:destroy(Panel),
    NewPanel = wxPanel:new(Frame),
    wxFrame:connect(NewPanel, paint),
 %  wxFrame:show(Frame),
    NewPanel.
