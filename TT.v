module TT(
    //Input Port
    clk,
    rst_n,
	in_valid,
    source,
    destination,

    //Output Port
    out_valid,
    cost
    );

input               clk, rst_n, in_valid;
input       [3:0]   source;
input       [3:0]   destination;

output reg          out_valid;
output reg  [3:0]   cost;

//==============================================//
//             Parameter and Integer            //
//==============================================//
parameter IDLE=3'd0,LOAD=3'd1,MAP=3'd2,CHECK_1=3'd3,PUT=3'd4,OR=3'd5,CHECK_2=3'd6,OUT=3'd7;
integer i,j;
//==============================================//
//            FSM State Declaration             //
//==============================================//
reg [2:0] cs,ns;
reg [3:0]source_0,destination_0;
//==============================================//
//                 reg declaration              //
//==============================================//
reg [15:0] map[0:15];
reg [15:0] result[0:1];
reg [15:0] row[0:15];

//==============================================//
//             Current State Block              //
//==============================================//

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cs <= IDLE; /* initial state */
    else 
        cs <= ns;
end

//==============================================//
//              Next State Block                //
//==============================================//

always@(*) begin
    case(cs)
    IDLE:begin  
        if(in_valid)
        begin
            ns=LOAD;
        end
        else begin
            ns=IDLE;
        end
    end
    LOAD:begin
        ns=MAP;
    end
    MAP:begin
        if(in_valid)
        begin   
            ns=MAP;
        end
        else begin  
            ns=CHECK_1;
        end
    end
    CHECK_1:begin
        if(map[source_0][destination_0]==1'b1||map[destination_0][source_0]==1'b1)
        begin
            ns=OUT;
        end
        else begin
            ns=PUT;
        end
    end
    PUT:begin
        ns=OR;
    end
    OR:begin
        ns=CHECK_2;
    end
    CHECK_2:begin
        if(result[0][source_0]==1'b1)
        begin
            ns=OUT;
        end
        else if(result[0]==result[1])
        begin
            ns=OUT;
        end
        else begin
            ns=PUT;
        end
    end
    OUT:begin
        ns=IDLE;
    end


    endcase
end

//==============================================//
//                  Input Block                 //
//==============================================//
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
    begin
        source_0=3'd0;
    end
    else if(ns == LOAD)
    begin
        source_0 = source;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
    begin
        destination_0=3'd0;
    end
    else if(ns == LOAD)
    begin
        destination_0 = destination;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
    begin
        for(i=0;i<16;i=i+1)
        begin   
            for(j=0;j<16;j=j+1)
            begin
                map[i][j]=1'b0;
            end
        end
    end
    else if(ns == IDLE)
    begin
        for(i=0;i<16;i=i+1)
        begin   
            for(j=0;j<16;j=j+1)
            begin
                map[i][j]=1'b0;
            end
        end
    end
    else if(ns == MAP)
    begin
        map[source][destination]=1'b1;
        map[destination][source]=1'b1;
		for(i=0;i<16;i=i+1)
		begin
			map[i][i]=1'b1;
		end
    end

end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
    begin
        for(i=0;i<16;i=i+1)
        begin
            row[i]=16'b0;
        end
    end
    else if(ns == IDLE)
    begin
        for(i=0;i<16;i=i+1)
        begin
            row[i]=16'b0;
        end
    end
    else if(ns == PUT)
    begin
        for(i=0;i<16;i=i+1)
        begin
            if(result[0][i]==1'b1)
            begin
                row[i]=map[i];
            end
            else begin
                row[i]=16'b0;
            end
        end
    end
end

//==============================================//
//              Calculation Block               //
//==============================================//
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
    begin
        result[0]=16'b0;
    end
    else if(ns == CHECK_1)
    begin
        result[0]=map[destination_0];
    end
    else if(ns == PUT)
    begin
        result[1]=result[0];
    end
    else if(ns == OR)
    begin
        result[0]=result[0]|row[0]|row[1]|row[2]|row[3]|row[4]|row[5]|row[6]|row[7]|row[8]|row[9]|row[10]|row[11]|row[12]|row[13]|row[14]|row[15];
    end
end

//==============================================//
//                Output Block                  //
//==============================================//
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
    begin
        cost <= 4'd0; /* remember to reset */
    end
    else if(ns == IDLE)
    begin
        cost <= 4'd0; /* remember to reset */
    end
    else if(ns == CHECK_1)
    begin
        if(map[source_0][destination_0]==1'b1||map[destination_0][source_0]==1'b1)
        begin
            if(source_0 == destination_0)
            begin
                cost<= 4'd0;
            end
            else begin
                cost<= 4'd1;
            end
        end
        else begin
            cost<= 4'd1;
        end
    end
    else if(ns == CHECK_2)
    begin
        if(result[0]==result[1])
        begin
            cost<=4'd0;
        end
        else 
        begin
            cost<=cost+4'd1;
        end
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) 
    begin
        out_valid <= 0; /* remember to reset */
    end
    else if(ns == IDLE)
    begin
        out_valid <= 1'b0;
    end
    else if(ns == OUT)
    begin
        out_valid <= 1'b1;
    end
end


endmodule 