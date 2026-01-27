module HazardDetectionUnit(
    input wire ID_Ex_Mem_Read,
    input wire Ex_Mem_Mem_Read,
    input wire[4:0] ID_Ex_rd,
    input wire[4:0] IF_Id_rs1,
    input wire[4:0] IF_Id_rs2,
    input wire is_branch,
    input wire ID_Ex_Reg_Write,
    input wire Ex_Mem_Reg_Write,
    input wire[4:0] Ex_Mem_rd,
    output wire stall
);
    wire load_use_hazard;
    wire branch_data_hazard;

    assign load_use_hazard = ID_Ex_Mem_Read && (ID_Ex_rd != 5'b0) &&
                   ((ID_Ex_rd == IF_Id_rs1) || (ID_Ex_rd == IF_Id_rs2));
        
    assign branch_data_hazard = is_branch && (
        (ID_Ex_Reg_Write && (ID_Ex_rd != 5'b0) &&
            ((ID_Ex_rd == IF_Id_rs1) || (ID_Ex_rd == IF_Id_rs2))) ||
        (Ex_Mem_Mem_Read && (Ex_Mem_rd != 5'b0) && 
            ((Ex_Mem_rd == IF_Id_rs1) || (Ex_Mem_rd == IF_Id_rs2)))
    );

    assign stall = load_use_hazard || branch_data_hazard;
endmodule
