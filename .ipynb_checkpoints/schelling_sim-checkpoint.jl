using Parameters, Plots, LinearAlgebra, PyPlot, Statistics, IJulia


Game = @with_kw (
    nrow = 20,
    ncol = 20,
    kindlist = [1 2],
    board = rand(0:maximum(kindlist), (nrow, ncol)),
    kindshare_thresh = 0.3
)

agent = @with_kw (
    x = rand(1:nrow), y = rand(1:ncol),
    kind
)

"""
Gets the share of neighbours for a given agent
who are of the same kind
"""
function a_neighbour_kindshare(a, game)
        
    neighbours = Vector{Int64}[]
    
    if a.kind == 0
        push!(neighbours, [-999])
    else
        for xadj in (-1, 0, 1)
            for yadj in (-1, 0, 1)
                if (a.x + xadj) ≤ game.nrow && (a.x + xadj) > 0 && (a.y + yadj) ≤ game.ncol && (a.y + yadj) > 0
                    newx = a.x + xadj
                    newy = a.y + yadj
                    board_pos_kind = game.board[newx, newy]
                    if !all((newx, newy) == (a.x, a.y))
                        samekind = a.kind == board_pos_kind
                        push!(neighbours, [samekind])
                    end
                end
            end
        end
    end
    
    if length(neighbours) == 0
        neighbours = [0]
    end
    kindshare = mean(neighbours)
    return kindshare[1]
end


"""
Get a matrix the same size as the board
with each block representing its
kind-share i.e. share of neighbours with
same type
"""
function get_game_kindshare(game)
    
    kindshare_mat = zeros(Float64, (game.nrow, game.ncol))
    
    for i in 1:game.nrow
        for j in 1:game.ncol
            a = agent(
                x = i,
                y = j,
                kind = game.board[i, j]
            )
            akindshare = a_neighbour_kindshare(a, game)
            kindshare_mat[i, j] = akindshare
        end
    end
    
    return kindshare_mat
    
end

function ishappy(a, game)
    
    kind_share = a_neighbour_kindshare(a, game)
    happy = kind_share ≥ game.kindshare_thresh
    
    return happy
    
end

function board_happy(game)
    
    board_ishappy = zero(game.board)
   
    for i in 1:game.nrow
        for j in 1:game.ncol
            
            if game.board[i, j] != 0
                a = agent(
                    x = i, y = j, kind = game.board[i, j]
                )
                board_ishappy[i, j] = ishappy(a, game)
            else
                board_ishappy[i, j] = -999
            end
        end
    end
    
    return board_ishappy
    
end


function new_move(a, game, method = "random")
    
    empty_spots = findall(a->a==0, game.board)
    
    if lowercase(method) == "random"
        
        if length(empty_spots) > 0
            random_idx = rand(1:length(empty_spots))
            move_loc = empty_spots[random_idx]
        else
            # dont move if there are no empty slots available
            move_loc = (a.x, a.y)
        end
        
    end
    
    return move_loc
    
    
end


function update_board!(a, game, newloc)
    
    oldloc = (a.x, a.y)
    
    # making old location empty
    game.board[oldloc...] = 0
    
    # updating new location
    game.board[newloc] = a.kind
    
end

function simuate_1period_board!(game, method = "random")

    happypositions = board_happy(game)
    tomove_board = happypositions .== 0
    tomove_idx = findall(tomove_board)
    for tomove in Tuple(tomove_idx)
        a = agent(
            x = tomove[1], y = tomove[2], kind = game.board[tomove]
        )
        newloc = new_move(a, game, method)
        update_board!(a, game, newloc)
    end

end

function simulate(initgame, board_happy_thresh = 1.0, maxiter = 100; plotout = false)
    
    # the only way to properly copy for now
    game = Game(
        nrow = initgame.nrow,
        ncol = initgame.ncol,
        board = initgame.board,
        kindlist = initgame.kindlist,
        kindshare_thresh = initgame.kindshare_thresh 
    )
    allhappy = false
    iter = 1
    
    if plotout
        anim = Animation()   
    end
    
    while !allhappy && iter ≤ maxiter
        
        if plotout
            
            plt = heatmap(game.board, legend = false, 
                            c=cgrad([:white, :blue]),
                             showaxis = false, ticks = false)
            frame(anim, plt) 
        end
        simuate_1period_board!(game)
        board_happy_mat = board_happy(game)
        board_happy_mat[board_happy_mat .== -999] .= 1
        board_happy_mean = mean(board_happy_mat)

        if board_happy_mean ≥ board_happy_thresh
            allhappy = true
        end
        
        iter += 1
    end
    
    if iter == maxiter
        println("Even after maximum iterations ($maxiter) not everyone was happy! :(")
    else
        println("Everyone is happy!")
    end
    
    if plotout
        gif(anim, "schelling_simulation.gif", fps=5)
    end
    
    return game
    
end


# Running Simulation

initgame = Game(nrow = 50, ncol = 50, kindshare_thresh = 0.3)
outgame = simulate(initgame, plotout = true)