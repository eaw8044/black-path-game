%{
2-Player game of Black Path
Input: config (3x2 matrix), optional
    #rows        #columns
    start_row    start_col
    start_dir    start_dir
%}
function blackpath(config)

    % CONSTANTS
    N = [-1 0]; S = [1 0]; E = [0 1]; W = [0 -1];

    % read in config
    dims = config(1,:);
    activeTileCoords = config(2,:);
    prevDir = config(3,:);
    player = 0;
    
    % TILES
    TILE_EMPTY = processTileImage('tiles_img/tile_empty.png');
    TILE_CROSS = processTileImage('tiles_img/tile_cross.png');
    TILE_NE = processTileImage('tiles_img/tile_truchetNE.png');
    TILE_NW = processTileImage('tiles_img/tile_truchetNW.png');
    TILE_ACTIVEN = processTileImage('tiles_img/tile_activeN.png');
    TILE_ACTIVEE = processTileImage('tiles_img/tile_activeE.png');
    TILE_ACTIVES = processTileImage('tiles_img/tile_activeS.png');
    TILE_ACTIVEW = processTileImage('tiles_img/tile_activeW.png');
    LEN_TILE = size(TILE_EMPTY,1);
    
    % Helper to update ui
    function placeTile(tile)
        tileOrigin = (activeTileCoords-1)*LEN_TILE+1;
        board_im(tileOrigin(1):tileOrigin(1)+LEN_TILE-1, tileOrigin(2):tileOrigin(2)+LEN_TILE-1) = tile;
        updateCurrentTile(tile);
        if size(activeTileCoords) > 0
            updateActiveTile()
            player = ~player;
        end
    end
    
    % Helper to update game state
    function updateCurrentTile(tile)
        newDir = [];
        if prevDir == N
            if tile == TILE_CROSS   newDir = N;
            elseif tile == TILE_NE  newDir = W;
            elseif tile == TILE_NW  newDir = E;
            end
        elseif prevDir == S
            if tile == TILE_CROSS   newDir = S;
            elseif tile == TILE_NE  newDir = E;
            elseif tile == TILE_NW  newDir = W;
            end
        elseif prevDir == E
            if tile == TILE_CROSS   newDir = E;
            elseif tile == TILE_NE  newDir = S;
            elseif tile == TILE_NW  newDir = N;
            end
        else
            if tile == TILE_CROSS   newDir = W;
            elseif tile == TILE_NE  newDir = N;
            elseif tile == TILE_NW  newDir = S;
            end
        end
        prevDir = newDir;
        activeTileCoords = activeTileCoords + newDir;
        
        if any(activeTileCoords < [1 1]) || any(activeTileCoords > dims)
            activeTileCoords = [];
            end_game(board_im, player);
        else
            tileOrigin = (activeTileCoords-1)*LEN_TILE+1;
            nextTile = board_im(tileOrigin(1):tileOrigin(1)+LEN_TILE-1, tileOrigin(2):tileOrigin(2)+LEN_TILE-1);
            if ~isequal(nextTile, TILE_EMPTY)
                updateCurrentTile(nextTile);
            end
        end
        
    end

    % Helper to set active tile
    function updateActiveTile()
        tileOrigin = (activeTileCoords-1)*LEN_TILE+1;
        activeTile = [];
        if prevDir == N     activeTile = TILE_ACTIVEN;
        elseif prevDir == E activeTile = TILE_ACTIVEE;
        elseif prevDir == S activeTile = TILE_ACTIVES;
        else                activeTile = TILE_ACTIVEW;
        end
        board_im(tileOrigin(1):tileOrigin(1)+LEN_TILE-1, tileOrigin(2):tileOrigin(2)+LEN_TILE-1) = activeTile;
        nexttile(ui, 1, dims);
        imshow(board_im);        
    end
    
    [board_im, ui] = get_board(...
        dims, ...
        TILE_EMPTY, ...
        cat(3, TILE_CROSS, TILE_NE, TILE_NW), ...
        @placeTile...
        );
    updateActiveTile();

end

function im = processTileImage(fn)
    im = imread(fn);
    im = im(:,:,1);
end

function [board_im, ui] = get_board(dims, tile_empty, tile_opts, optClbk)
    
    % create empty board
    board_im = repmat(tile_empty, dims(1), dims(2));
    
    % open new figure
    figure
    ui = tiledlayout(dims(1)+2, dims(2));
    
    % add grid
    nexttile(1, dims), imshow(board_im);
    
    % add options
    num_opts = size(tile_opts, 3);
    opts_tile = tiledlayout(ui, 1, num_opts);
    title(opts_tile, 'Choose a tile to play');
    opts_tile.Layout.Tile = dims(1)*dims(2)+1;
    opts_tile.Layout.TileSpan = [2 dims(2)];
    for o = 1:num_opts
        curr_opt = tile_opts(:,:,o);
        curr_tile = nexttile(opts_tile);
        curr_tile.PickableParts = 'all';
        curr_tile.ButtonDownFcn = @(btn,evt) optClbk(curr_opt);
        hold on;
        curr_im = imshow(curr_opt);
        set(curr_im, 'HitTest', 'off');
    end

end

function end_game(board_im, player)
    clf('reset');
    imshow(board_im);
    if player title('GAME OVER: Player 1 wins!');
    else title('GAME OVER: Player 2 wins!');
    end
end
