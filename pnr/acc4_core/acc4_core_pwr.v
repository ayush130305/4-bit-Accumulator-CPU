module acc4_core (clk,
    halt_pn,
    rd_pn,
    rst_n,
    run,
    we_pn,
    addr_pn,
    din,
    dout_pn);
 input clk;
 output halt_pn;
 output rd_pn;
 input rst_n;
 input run;
 output we_pn;
 output [4:0] addr_pn;
 input [7:0] din;
 output [3:0] dout_pn;

 wire _000_;
 wire _001_;
 wire _002_;
 wire _003_;
 wire _004_;
 wire _005_;
 wire _006_;
 wire _007_;
 wire _008_;
 wire _009_;
 wire _010_;
 wire _011_;
 wire _012_;
 wire _013_;
 wire _014_;
 wire _015_;
 wire _016_;
 wire _017_;
 wire _018_;
 wire _019_;
 wire _020_;
 wire _021_;
 wire _022_;
 wire _023_;
 wire _024_;
 wire _025_;
 wire _026_;
 wire _027_;
 wire _028_;
 wire _029_;
 wire _030_;
 wire _031_;
 wire _032_;
 wire _033_;
 wire _034_;
 wire _035_;
 wire _036_;
 wire _037_;
 wire _038_;
 wire _039_;
 wire _040_;
 wire _041_;
 wire _042_;
 wire _043_;
 wire _044_;
 wire _045_;
 wire _046_;
 wire _047_;
 wire _048_;
 wire _049_;
 wire _050_;
 wire _051_;
 wire _052_;
 wire _053_;
 wire _054_;
 wire _055_;
 wire _056_;
 wire _057_;
 wire _058_;
 wire _059_;
 wire _060_;
 wire _061_;
 wire _062_;
 wire _063_;
 wire _064_;
 wire _065_;
 wire _066_;
 wire _067_;
 wire _068_;
 wire _069_;
 wire _070_;
 wire _071_;
 wire _072_;
 wire _073_;
 wire _074_;
 wire _075_;
 wire _076_;
 wire _077_;
 wire _078_;
 wire _079_;
 wire _080_;
 wire _081_;
 wire _082_;
 wire _083_;
 wire _084_;
 wire _085_;
 wire _086_;
 wire _087_;
 wire _088_;
 wire _089_;
 wire _090_;
 wire _091_;
 wire _092_;
 wire _093_;
 wire _094_;
 wire _095_;
 wire _096_;
 wire _097_;
 wire _098_;
 wire _099_;
 wire _100_;
 wire _101_;
 wire _102_;
 wire _103_;
 wire _104_;
 wire _105_;
 wire _106_;
 wire _107_;
 wire _108_;
 wire _109_;
 wire _110_;
 wire _111_;
 wire _112_;
 wire _113_;
 wire _114_;
 wire _115_;
 wire _116_;
 wire _117_;
 wire _118_;
 wire _119_;
 wire _120_;
 wire _121_;
 wire _122_;
 wire _123_;
 wire _124_;
 wire _125_;
 wire _126_;
 wire _127_;
 wire _128_;
 wire _129_;
 wire _130_;
 wire _131_;
 wire _132_;
 wire _133_;
 wire _134_;
 wire _135_;
 wire _136_;
 wire _137_;
 wire _138_;
 wire _139_;
 wire _140_;
 wire _141_;
 wire _142_;
 wire _143_;
 wire _144_;
 wire _145_;
 wire _146_;
 wire halt;
 wire rd;
 wire \u_cpu.we ;
 wire net1;
 wire net2;
 wire net3;
 wire net4;
 wire net5;
 wire net6;
 wire net7;
 wire net8;
 wire net9;
 wire net10;
 wire net11;
 wire net12;
 wire net13;
 wire net14;
 wire net15;
 wire net16;
 wire net17;
 wire net18;
 wire net19;
 wire net20;
 wire net21;
 wire net22;
 wire net23;
 wire net24;
 wire net25;
 wire net26;
 wire net27;
 wire net28;
 wire net29;
 wire net30;
 wire net31;
 wire net32;
 wire net33;
 wire net34;
 wire net35;
 wire net36;
 wire net37;
 wire net38;
 wire net39;
 wire net40;
 wire net41;
 wire net42;
 wire net43;
 wire net44;
 wire net45;
 wire net46;
 wire net47;
 wire net48;
 wire net49;
 wire net50;
 wire net51;
 wire net52;
 wire net53;
 wire net54;
 wire net55;
 wire net56;
 wire net57;
 wire net58;
 wire net59;
 wire net60;
 wire net61;
 wire net62;
 wire net63;
 wire net64;
 wire net65;
 wire net66;
 wire net67;
 wire net68;
 wire net69;
 wire net70;
 wire net71;
 wire net72;
 wire net73;
 wire net74;
 wire net75;
 wire net76;
 wire net77;
 wire net78;
 wire net79;
 wire net80;
 wire net81;
 wire net82;
 wire net83;
 wire net84;
 wire net85;
 wire net86;
 wire net87;
 wire net88;
 wire net89;
 wire net90;
 wire net91;
 wire net92;
 wire net93;
 wire net94;
 wire net95;
 wire net96;
 wire net97;
 wire net98;
 wire net99;
 wire net100;
 wire net101;
 wire net102;
 wire net103;
 wire net104;
 wire net105;
 wire net106;
 wire net107;
 wire net108;
 wire net109;
 wire net110;
 wire net111;
 wire net112;
 wire net113;
 wire net114;
 wire net115;
 wire net116;
 wire net117;
 wire net118;
 wire net119;
 wire net120;
 wire net121;
 wire net122;
 wire net123;
 wire net124;
 wire net125;
 wire net126;
 wire net127;
 wire net128;
 wire net129;
 wire net130;
 wire net131;
 wire net132;
 wire net133;
 wire net134;
 wire net135;
 wire net136;
 wire net137;
 wire net138;
 wire net139;
 wire net140;
 wire clknet_0_clk;
 wire clknet_1_0__leaf_clk;
 wire clknet_1_1__leaf_clk;
 wire [4:0] addr;
 wire [3:0] dout;
 wire [7:0] \u_cpu.ir ;
 wire [4:0] \u_cpu.pc ;
 wire [1:0] \u_cpu.state ;

 INVR01 _147_ (.OUT1(_099_),
    .VSS(VSS),
    .IN1(net86),
    .VDD(VDD));
 INVR01 _148_ (.OUT1(_100_),
    .VSS(VSS),
    .IN1(net96),
    .VDD(VDD));
 INVR01 _149_ (.OUT1(_101_),
    .VSS(VSS),
    .IN1(run),
    .VDD(VDD));
 INVR01 _150_ (.OUT1(_102_),
    .VSS(VSS),
    .IN1(\u_cpu.state [0]),
    .VDD(VDD));
 INVR01 _151_ (.OUT1(_103_),
    .VSS(VSS),
    .IN1(\u_cpu.state [1]),
    .VDD(VDD));
 INVR01 _152_ (.OUT1(_104_),
    .VSS(VSS),
    .IN1(net123),
    .VDD(VDD));
 INVR01 _153_ (.OUT1(_105_),
    .VSS(VSS),
    .IN1(dout[0]),
    .VDD(VDD));
 INVR01 _154_ (.OUT1(_106_),
    .VSS(VSS),
    .IN1(net119),
    .VDD(VDD));
 INVR01 _155_ (.OUT1(_107_),
    .VSS(VSS),
    .IN1(net120),
    .VDD(VDD));
 INVR01 _156_ (.OUT1(_108_),
    .VSS(VSS),
    .IN1(net127),
    .VDD(VDD));
 INVR01 _157_ (.OUT1(_109_),
    .VSS(VSS),
    .IN1(net126),
    .VDD(VDD));
 INVR01 _158_ (.OUT1(_110_),
    .VSS(VSS),
    .IN1(_002_),
    .VDD(VDD));
 NOR200 _159_ (.OUT1(halt),
    .VSS(VSS),
    .IN1(\u_cpu.state [0]),
    .IN2(_103_),
    .VDD(VDD));
 NOR200 _160_ (.OUT1(_111_),
    .VSS(VSS),
    .IN1(_102_),
    .IN2(\u_cpu.state [1]),
    .VDD(VDD));
 MX2101 _161_ (.D0(net138),
    .OUT1(addr[0]),
    .A0(net56),
    .D1(net114),
    .VSS(VSS),
    .VDD(VDD));
 MX2101 _162_ (.D0(net134),
    .OUT1(addr[1]),
    .A0(net57),
    .D1(net109),
    .VSS(VSS),
    .VDD(VDD));
 MX2101 _163_ (.D0(net131),
    .OUT1(addr[2]),
    .A0(net63),
    .D1(net105),
    .VSS(VSS),
    .VDD(VDD));
 MX2101 _164_ (.D0(net128),
    .OUT1(addr[3]),
    .A0(net66),
    .D1(net102),
    .VSS(VSS),
    .VDD(VDD));
 MX2101 _165_ (.D0(net124),
    .OUT1(addr[4]),
    .A0(net71),
    .D1(net99),
    .VSS(VSS),
    .VDD(VDD));
 OR2101 _166_ (.OUT1(_112_),
    .VSS(VSS),
    .IN1(_101_),
    .IN2(\u_cpu.state [1]),
    .VDD(VDD));
 ORND01 _167_ (.A(net86),
    .B(_100_),
    .C(_002_),
    .OUT1(_113_),
    .VSS(VSS),
    .VDD(VDD));
 ADNR01 _168_ (.A(net83),
    .B(_099_),
    .C(_102_),
    .OUT1(_114_),
    .VSS(VSS),
    .VDD(VDD));
 ADNR01 _169_ (.A(_113_),
    .B(_114_),
    .C(_112_),
    .OUT1(rd),
    .VSS(VSS),
    .VDD(VDD));
 NOR300 _170_ (.OUT1(_115_),
    .VSS(VSS),
    .IN1(net84),
    .IN2(net86),
    .IN3(_100_),
    .VDD(VDD));
 AND301 _171_ (.OUT1(\u_cpu.we ),
    .VSS(VSS),
    .IN1(run),
    .IN2(net61),
    .IN3(_115_),
    .VDD(VDD));
 NOR200 _172_ (.OUT1(_116_),
    .VSS(VSS),
    .IN1(\u_cpu.state [0]),
    .IN2(_112_),
    .VDD(VDD));
 AND201 _173_ (.OUT1(_117_),
    .VSS(VSS),
    .IN1(net88),
    .IN2(net96),
    .VDD(VDD));
 NOR200 _174_ (.OUT1(_118_),
    .VSS(VSS),
    .IN1(_099_),
    .IN2(net96),
    .VDD(VDD));
 OR2101 _175_ (.OUT1(_119_),
    .VSS(VSS),
    .IN1(_099_),
    .IN2(net94),
    .VDD(VDD));
 AND201 _176_ (.OUT1(_120_),
    .VSS(VSS),
    .IN1(net85),
    .IN2(net86),
    .VDD(VDD));
 OR4101 _177_ (.OUT1(_121_),
    .VSS(VSS),
    .IN1(net122),
    .IN2(dout[0]),
    .IN3(dout[3]),
    .IN4(net121),
    .VDD(VDD));
 NND300 _178_ (.OUT1(_122_),
    .VSS(VSS),
    .IN1(net85),
    .IN2(_117_),
    .IN3(_121_),
    .VDD(VDD));
 AND401 _179_ (.OUT1(_123_),
    .VSS(VSS),
    .IN1(run),
    .IN2(_103_),
    .IN3(_120_),
    .IN4(_122_),
    .VDD(VDD));
 OR2101 _180_ (.OUT1(_124_),
    .VSS(VSS),
    .IN1(net45),
    .IN2(_123_),
    .VDD(VDD));
 MX2101 _181_ (.D0(net136),
    .OUT1(_125_),
    .A0(net56),
    .D1(net115),
    .VSS(VSS),
    .VDD(VDD));
 MX2101 _182_ (.D0(net139),
    .OUT1(_003_),
    .A0(net12),
    .D1(net16),
    .VSS(VSS),
    .VDD(VDD));
 AND201 _183_ (.OUT1(_126_),
    .VSS(VSS),
    .IN1(net137),
    .IN2(net133),
    .VDD(VDD));
 INVR01 _184_ (.OUT1(_127_),
    .VSS(VSS),
    .IN1(_126_),
    .VDD(VDD));
 NOR200 _185_ (.OUT1(_128_),
    .VSS(VSS),
    .IN1(net140),
    .IN2(net133),
    .VDD(VDD));
 NOR200 _186_ (.OUT1(_129_),
    .VSS(VSS),
    .IN1(_126_),
    .IN2(net77),
    .VDD(VDD));
 MX2101 _187_ (.D0(net41),
    .OUT1(_130_),
    .A0(net59),
    .D1(net110),
    .VSS(VSS),
    .VDD(VDD));
 MX2101 _188_ (.D0(net135),
    .OUT1(_004_),
    .A0(net12),
    .D1(net15),
    .VSS(VSS),
    .VDD(VDD));
 NOR200 _189_ (.OUT1(_022_),
    .VSS(VSS),
    .IN1(net131),
    .IN2(_127_),
    .VDD(VDD));
 MX2101 _190_ (.D0(net14),
    .OUT1(_023_),
    .A0(net63),
    .D1(net106),
    .VSS(VSS),
    .VDD(VDD));
 ORND01 _191_ (.A(net68),
    .B(_126_),
    .C(net12),
    .OUT1(_024_),
    .VSS(VSS),
    .VDD(VDD));
 AOI401 _192_ (.A(net12),
    .B(_023_),
    .C(_024_),
    .D(net130),
    .OUT1(_025_),
    .VSS(VSS),
    .VDD(VDD));
 INVR01 _193_ (.OUT1(_005_),
    .VSS(VSS),
    .IN1(_025_),
    .VDD(VDD));
 NOR300 _194_ (.OUT1(_026_),
    .VSS(VSS),
    .IN1(_000_),
    .IN2(net64),
    .IN3(_127_),
    .VDD(VDD));
 MX2101 _195_ (.D0(net21),
    .OUT1(_027_),
    .A0(_026_),
    .D1(net82),
    .VSS(VSS),
    .VDD(VDD));
 MX2101 _196_ (.D0(net129),
    .OUT1(_006_),
    .A0(net13),
    .D1(net11),
    .VSS(VSS),
    .VDD(VDD));
 NND300 _197_ (.OUT1(_028_),
    .VSS(VSS),
    .IN1(net130),
    .IN2(\u_cpu.pc [3]),
    .IN3(_126_),
    .VDD(VDD));
 NOR200 _198_ (.OUT1(_029_),
    .VSS(VSS),
    .IN1(net67),
    .IN2(_028_),
    .VDD(VDD));
 MX2101 _199_ (.D0(net19),
    .OUT1(_030_),
    .A0(_029_),
    .D1(net81),
    .VSS(VSS),
    .VDD(VDD));
 MX2101 _200_ (.D0(net125),
    .OUT1(_007_),
    .A0(net13),
    .D1(net10),
    .VSS(VSS),
    .VDD(VDD));
 NOR200 _201_ (.OUT1(_031_),
    .VSS(VSS),
    .IN1(run),
    .IN2(_102_),
    .VDD(VDD));
 OR2101 _202_ (.OUT1(_008_),
    .VSS(VSS),
    .IN1(net43),
    .IN2(_031_),
    .VDD(VDD));
 XNR201 _203_ (.OUT1(_032_),
    .VSS(VSS),
    .IN1(net126),
    .IN2(net100),
    .VDD(VDD));
 XNR201 _204_ (.OUT1(_033_),
    .VSS(VSS),
    .IN1(net132),
    .IN2(net108),
    .VDD(VDD));
 XNR201 _205_ (.OUT1(_034_),
    .VSS(VSS),
    .IN1(_108_),
    .IN2(net103),
    .VDD(VDD));
 AND201 _206_ (.OUT1(_035_),
    .VSS(VSS),
    .IN1(_000_),
    .IN2(net78),
    .VDD(VDD));
 OR4101 _207_ (.OUT1(_036_),
    .VSS(VSS),
    .IN1(net140),
    .IN2(\u_cpu.pc [1]),
    .IN3(net132),
    .IN4(net127),
    .VDD(VDD));
 XOR201 _208_ (.OUT1(_037_),
    .VSS(VSS),
    .IN1(net137),
    .IN2(net118),
    .VDD(VDD));
 AND501 _209_ (.OUT1(_038_),
    .VSS(VSS),
    .IN1(net83),
    .IN2(run),
    .IN3(net62),
    .IN4(_118_),
    .IN5(_037_),
    .VDD(VDD));
 XNR201 _210_ (.OUT1(_039_),
    .VSS(VSS),
    .IN1(net77),
    .IN2(_033_),
    .VDD(VDD));
 XNR201 _211_ (.OUT1(_040_),
    .VSS(VSS),
    .IN1(net113),
    .IN2(_129_),
    .VDD(VDD));
 XNR201 _212_ (.OUT1(_041_),
    .VSS(VSS),
    .IN1(_034_),
    .IN2(_035_),
    .VDD(VDD));
 XNR201 _213_ (.OUT1(_042_),
    .VSS(VSS),
    .IN1(_032_),
    .IN2(_036_),
    .VDD(VDD));
 NND300 _214_ (.OUT1(_043_),
    .VSS(VSS),
    .IN1(_038_),
    .IN2(_041_),
    .IN3(_042_),
    .VDD(VDD));
 NOR300 _215_ (.OUT1(_044_),
    .VSS(VSS),
    .IN1(_039_),
    .IN2(_040_),
    .IN3(_043_),
    .VDD(VDD));
 OR2101 _216_ (.OUT1(_009_),
    .VSS(VSS),
    .IN1(\u_cpu.state [1]),
    .IN2(_044_),
    .VDD(VDD));
 OR2101 _217_ (.OUT1(_045_),
    .VSS(VSS),
    .IN1(_115_),
    .IN2(_120_),
    .VDD(VDD));
 NOR300 _218_ (.OUT1(_046_),
    .VSS(VSS),
    .IN1(_102_),
    .IN2(_112_),
    .IN3(_045_),
    .VDD(VDD));
 NOR300 _219_ (.OUT1(_047_),
    .VSS(VSS),
    .IN1(net89),
    .IN2(net94),
    .IN3(_110_),
    .VDD(VDD));
 NND300 _220_ (.OUT1(_048_),
    .VSS(VSS),
    .IN1(_099_),
    .IN2(_100_),
    .IN3(_002_),
    .VDD(VDD));
 NOR200 _221_ (.OUT1(_049_),
    .VSS(VSS),
    .IN1(_105_),
    .IN2(net37),
    .VDD(VDD));
 ADNR01 _222_ (.A(din[0]),
    .B(net1),
    .C(_049_),
    .OUT1(_050_),
    .VSS(VSS),
    .VDD(VDD));
 AND201 _223_ (.OUT1(_051_),
    .VSS(VSS),
    .IN1(dout[0]),
    .IN2(din[0]),
    .VDD(VDD));
 NOR300 _224_ (.OUT1(_052_),
    .VSS(VSS),
    .IN1(net89),
    .IN2(net94),
    .IN3(_002_),
    .VDD(VDD));
 MX2101 _225_ (.D0(net76),
    .OUT1(_053_),
    .A0(_051_),
    .D1(net90),
    .VSS(VSS),
    .VDD(VDD));
 OR2101 _226_ (.OUT1(_054_),
    .VSS(VSS),
    .IN1(_105_),
    .IN2(net1),
    .VDD(VDD));
 ORND01 _227_ (.A(_050_),
    .B(_053_),
    .C(_054_),
    .OUT1(_010_),
    .VSS(VSS),
    .VDD(VDD));
 AND201 _228_ (.OUT1(_055_),
    .VSS(VSS),
    .IN1(net122),
    .IN2(din[1]),
    .VDD(VDD));
 NOR200 _229_ (.OUT1(_056_),
    .VSS(VSS),
    .IN1(net122),
    .IN2(din[1]),
    .VDD(VDD));
 XOR201 _230_ (.OUT1(_057_),
    .VSS(VSS),
    .IN1(net122),
    .IN2(din[1]),
    .VDD(VDD));
 XNR201 _231_ (.OUT1(_058_),
    .VSS(VSS),
    .IN1(_051_),
    .IN2(_057_),
    .VDD(VDD));
 NOR200 _232_ (.OUT1(_059_),
    .VSS(VSS),
    .IN1(_119_),
    .IN2(_058_),
    .VDD(VDD));
 ADNR01 _233_ (.A(_105_),
    .B(din[0]),
    .C(_057_),
    .OUT1(_060_),
    .VSS(VSS),
    .VDD(VDD));
 NND300 _234_ (.OUT1(_061_),
    .VSS(VSS),
    .IN1(_105_),
    .IN2(din[0]),
    .IN3(_057_),
    .VDD(VDD));
 NND300 _235_ (.OUT1(_062_),
    .VSS(VSS),
    .IN1(net91),
    .IN2(net95),
    .IN3(_061_),
    .VDD(VDD));
 NOR200 _236_ (.OUT1(_063_),
    .VSS(VSS),
    .IN1(net94),
    .IN2(_055_),
    .VDD(VDD));
 NOR300 _237_ (.OUT1(_064_),
    .VSS(VSS),
    .IN1(net89),
    .IN2(_056_),
    .IN3(_063_),
    .VDD(VDD));
 NOR300 _238_ (.OUT1(_065_),
    .VSS(VSS),
    .IN1(net37),
    .IN2(_059_),
    .IN3(_064_),
    .VDD(VDD));
 ORND01 _239_ (.A(net28),
    .B(_062_),
    .C(_065_),
    .OUT1(_066_),
    .VSS(VSS),
    .VDD(VDD));
 OR2101 _240_ (.OUT1(_067_),
    .VSS(VSS),
    .IN1(din[1]),
    .IN2(net33),
    .VDD(VDD));
 NND300 _241_ (.OUT1(_068_),
    .VSS(VSS),
    .IN1(net2),
    .IN2(_066_),
    .IN3(_067_),
    .VDD(VDD));
 ORND01 _242_ (.A(_104_),
    .B(net2),
    .C(_068_),
    .OUT1(_011_),
    .VSS(VSS),
    .VDD(VDD));
 NOR200 _243_ (.OUT1(_069_),
    .VSS(VSS),
    .IN1(_107_),
    .IN2(net4),
    .VDD(VDD));
 XNR201 _244_ (.OUT1(_070_),
    .VSS(VSS),
    .IN1(net120),
    .IN2(din[2]),
    .VDD(VDD));
 NOR200 _245_ (.OUT1(_071_),
    .VSS(VSS),
    .IN1(_104_),
    .IN2(din[1]),
    .VDD(VDD));
 OR3101 _246_ (.OUT1(_072_),
    .VSS(VSS),
    .IN1(net28),
    .IN2(net75),
    .IN3(_071_),
    .VDD(VDD));
 ORND01 _247_ (.A(net29),
    .B(_071_),
    .C(_070_),
    .OUT1(_073_),
    .VSS(VSS),
    .VDD(VDD));
 NND300 _248_ (.OUT1(_074_),
    .VSS(VSS),
    .IN1(_117_),
    .IN2(_072_),
    .IN3(_073_),
    .VDD(VDD));
 ADNR01 _249_ (.A(_051_),
    .B(_057_),
    .C(_055_),
    .OUT1(_075_),
    .VSS(VSS),
    .VDD(VDD));
 ORND01 _250_ (.A(net75),
    .B(net24),
    .C(net42),
    .OUT1(_076_),
    .VSS(VSS),
    .VDD(VDD));
 ADNR01 _251_ (.A(net75),
    .B(net24),
    .C(_076_),
    .OUT1(_077_),
    .VSS(VSS),
    .VDD(VDD));
 AND201 _252_ (.OUT1(_078_),
    .VSS(VSS),
    .IN1(net120),
    .IN2(din[2]),
    .VDD(VDD));
 INVR01 _253_ (.OUT1(_079_),
    .VSS(VSS),
    .IN1(_078_),
    .VDD(VDD));
 NOR200 _254_ (.OUT1(_080_),
    .VSS(VSS),
    .IN1(net95),
    .IN2(_078_),
    .VDD(VDD));
 NOR200 _255_ (.OUT1(_081_),
    .VSS(VSS),
    .IN1(net120),
    .IN2(din[2]),
    .VDD(VDD));
 NOR300 _256_ (.OUT1(_082_),
    .VSS(VSS),
    .IN1(net91),
    .IN2(_080_),
    .IN3(_081_),
    .VDD(VDD));
 NOR300 _257_ (.OUT1(_083_),
    .VSS(VSS),
    .IN1(net38),
    .IN2(_077_),
    .IN3(_082_),
    .VDD(VDD));
 ORND01 _258_ (.A(din[2]),
    .B(net34),
    .C(net5),
    .OUT1(_084_),
    .VSS(VSS),
    .VDD(VDD));
 ADNR01 _259_ (.A(_074_),
    .B(_083_),
    .C(_084_),
    .OUT1(_085_),
    .VSS(VSS),
    .VDD(VDD));
 OR2101 _260_ (.OUT1(_012_),
    .VSS(VSS),
    .IN1(_069_),
    .IN2(_085_),
    .VDD(VDD));
 OR2101 _261_ (.OUT1(_086_),
    .VSS(VSS),
    .IN1(_106_),
    .IN2(net6),
    .VDD(VDD));
 NOR200 _262_ (.OUT1(_087_),
    .VSS(VSS),
    .IN1(net119),
    .IN2(din[3]),
    .VDD(VDD));
 XNR201 _263_ (.OUT1(_088_),
    .VSS(VSS),
    .IN1(_106_),
    .IN2(din[3]),
    .VDD(VDD));
 ORND01 _264_ (.A(_107_),
    .B(din[2]),
    .C(_073_),
    .OUT1(_089_),
    .VSS(VSS),
    .VDD(VDD));
 XNR201 _265_ (.OUT1(_090_),
    .VSS(VSS),
    .IN1(_088_),
    .IN2(_089_),
    .VDD(VDD));
 ORND01 _266_ (.A(net75),
    .B(net25),
    .C(_079_),
    .OUT1(_091_),
    .VSS(VSS),
    .VDD(VDD));
 XNR201 _267_ (.OUT1(_092_),
    .VSS(VSS),
    .IN1(_088_),
    .IN2(_091_),
    .VDD(VDD));
 ADNR01 _268_ (.A(net119),
    .B(din[3]),
    .C(net95),
    .OUT1(_093_),
    .VSS(VSS),
    .VDD(VDD));
 NOR300 _269_ (.OUT1(_094_),
    .VSS(VSS),
    .IN1(net87),
    .IN2(_087_),
    .IN3(_093_),
    .VDD(VDD));
 NOR200 _270_ (.OUT1(_095_),
    .VSS(VSS),
    .IN1(net38),
    .IN2(_094_),
    .VDD(VDD));
 ORND01 _271_ (.A(_119_),
    .B(_092_),
    .C(_095_),
    .OUT1(_096_),
    .VSS(VSS),
    .VDD(VDD));
 ADNR01 _272_ (.A(_117_),
    .B(_090_),
    .C(_096_),
    .OUT1(_097_),
    .VSS(VSS),
    .VDD(VDD));
 ORND01 _273_ (.A(din[3]),
    .B(net33),
    .C(net6),
    .OUT1(_098_),
    .VSS(VSS),
    .VDD(VDD));
 ORND01 _274_ (.A(_097_),
    .B(_098_),
    .C(_086_),
    .OUT1(_013_),
    .VSS(VSS),
    .VDD(VDD));
 MX2101 _275_ (.D0(net116),
    .OUT1(_014_),
    .A0(net45),
    .D1(din[0]),
    .VSS(VSS),
    .VDD(VDD));
 MX2101 _276_ (.D0(net112),
    .OUT1(_015_),
    .A0(net44),
    .D1(din[1]),
    .VSS(VSS),
    .VDD(VDD));
 MX2101 _277_ (.D0(net104),
    .OUT1(_016_),
    .A0(net47),
    .D1(din[2]),
    .VSS(VSS),
    .VDD(VDD));
 MX2101 _278_ (.D0(net101),
    .OUT1(_017_),
    .A0(net48),
    .D1(din[3]),
    .VSS(VSS),
    .VDD(VDD));
 MX2101 _279_ (.D0(net98),
    .OUT1(_018_),
    .A0(net47),
    .D1(din[4]),
    .VSS(VSS),
    .VDD(VDD));
 MX2101 _280_ (.D0(net97),
    .OUT1(_019_),
    .A0(net53),
    .D1(din[5]),
    .VSS(VSS),
    .VDD(VDD));
 MX2101 _281_ (.D0(net88),
    .OUT1(_020_),
    .A0(net53),
    .D1(din[6]),
    .VSS(VSS),
    .VDD(VDD));
 MX2101 _282_ (.D0(net84),
    .OUT1(_021_),
    .A0(net43),
    .D1(din[7]),
    .VSS(VSS),
    .VDD(VDD));
 DFCL11 _283_ (.Q(\u_cpu.pc [0]),
    .C(clknet_1_0__leaf_clk),
    .D(_003_),
    .QB(_001_),
    .VSS(VSS),
    .CLRB(rst_n),
    .VDD(VDD));
 DFCL11 _284_ (.Q(\u_cpu.pc [1]),
    .C(clknet_1_0__leaf_clk),
    .D(_004_),
    .QB(_136_),
    .VSS(VSS),
    .CLRB(rst_n),
    .VDD(VDD));
 DFCL11 _285_ (.Q(\u_cpu.pc [2]),
    .C(clknet_1_0__leaf_clk),
    .D(_005_),
    .QB(_000_),
    .VSS(VSS),
    .CLRB(rst_n),
    .VDD(VDD));
 DFCL11 _286_ (.Q(\u_cpu.pc [3]),
    .C(clknet_1_0__leaf_clk),
    .D(_006_),
    .QB(_135_),
    .VSS(VSS),
    .CLRB(rst_n),
    .VDD(VDD));
 DFCL11 _287_ (.Q(\u_cpu.pc [4]),
    .C(clknet_1_0__leaf_clk),
    .D(_007_),
    .QB(_134_),
    .VSS(VSS),
    .CLRB(rst_n),
    .VDD(VDD));
 DFCL11 _288_ (.Q(\u_cpu.state [0]),
    .C(clknet_1_0__leaf_clk),
    .D(_008_),
    .QB(_133_),
    .VSS(VSS),
    .CLRB(rst_n),
    .VDD(VDD));
 DFCL11 _289_ (.Q(\u_cpu.state [1]),
    .C(clknet_1_0__leaf_clk),
    .D(_009_),
    .QB(_132_),
    .VSS(VSS),
    .CLRB(rst_n),
    .VDD(VDD));
 DFCL11 _290_ (.Q(dout[0]),
    .C(clknet_1_1__leaf_clk),
    .D(_010_),
    .QB(_131_),
    .VSS(VSS),
    .CLRB(rst_n),
    .VDD(VDD));
 DFCL11 _291_ (.Q(dout[1]),
    .C(clknet_1_1__leaf_clk),
    .D(_011_),
    .QB(_146_),
    .VSS(VSS),
    .CLRB(rst_n),
    .VDD(VDD));
 DFCL11 _292_ (.Q(dout[2]),
    .C(clknet_1_1__leaf_clk),
    .D(_012_),
    .QB(_145_),
    .VSS(VSS),
    .CLRB(rst_n),
    .VDD(VDD));
 DFCL11 _293_ (.Q(dout[3]),
    .C(clknet_1_1__leaf_clk),
    .D(_013_),
    .QB(_144_),
    .VSS(VSS),
    .CLRB(rst_n),
    .VDD(VDD));
 DFCL11 _294_ (.Q(\u_cpu.ir [0]),
    .C(clknet_1_0__leaf_clk),
    .D(_014_),
    .QB(_143_),
    .VSS(VSS),
    .CLRB(rst_n),
    .VDD(VDD));
 DFCL11 _295_ (.Q(\u_cpu.ir [1]),
    .C(clknet_1_0__leaf_clk),
    .D(_015_),
    .QB(_142_),
    .VSS(VSS),
    .CLRB(rst_n),
    .VDD(VDD));
 DFCL11 _296_ (.Q(\u_cpu.ir [2]),
    .C(clknet_1_1__leaf_clk),
    .D(_016_),
    .QB(_141_),
    .VSS(VSS),
    .CLRB(rst_n),
    .VDD(VDD));
 DFCL11 _297_ (.Q(\u_cpu.ir [3]),
    .C(clknet_1_1__leaf_clk),
    .D(_017_),
    .QB(_140_),
    .VSS(VSS),
    .CLRB(rst_n),
    .VDD(VDD));
 DFCL11 _298_ (.Q(\u_cpu.ir [4]),
    .C(clknet_1_0__leaf_clk),
    .D(_018_),
    .QB(_139_),
    .VSS(VSS),
    .CLRB(rst_n),
    .VDD(VDD));
 DFCL11 _299_ (.Q(\u_cpu.ir [5]),
    .C(clknet_1_1__leaf_clk),
    .D(_019_),
    .QB(_138_),
    .VSS(VSS),
    .CLRB(rst_n),
    .VDD(VDD));
 DFCL11 _300_ (.Q(\u_cpu.ir [6]),
    .C(clknet_1_1__leaf_clk),
    .D(_020_),
    .QB(_137_),
    .VSS(VSS),
    .CLRB(rst_n),
    .VDD(VDD));
 DFCL11 _301_ (.Q(\u_cpu.ir [7]),
    .C(clknet_1_1__leaf_clk),
    .D(_021_),
    .QB(_002_),
    .VSS(VSS),
    .CLRB(rst_n),
    .VDD(VDD));
 INVR05 u_drv_addr0 (.OUT1(addr_pn[0]),
    .VSS(VSS),
    .IN1(addr[0]),
    .VDD(VDD));
 INVR05 u_drv_addr1 (.OUT1(addr_pn[1]),
    .VSS(VSS),
    .IN1(addr[1]),
    .VDD(VDD));
 INVR05 u_drv_addr2 (.OUT1(addr_pn[2]),
    .VSS(VSS),
    .IN1(addr[2]),
    .VDD(VDD));
 INVR05 u_drv_addr3 (.OUT1(addr_pn[3]),
    .VSS(VSS),
    .IN1(net22),
    .VDD(VDD));
 INVR05 u_drv_addr4 (.OUT1(addr_pn[4]),
    .VSS(VSS),
    .IN1(net20),
    .VDD(VDD));
 INVR05 u_drv_dout0 (.OUT1(dout_pn[0]),
    .VSS(VSS),
    .IN1(dout[0]),
    .VDD(VDD));
 INVR05 u_drv_dout1 (.OUT1(dout_pn[1]),
    .VSS(VSS),
    .IN1(net123),
    .VDD(VDD));
 INVR05 u_drv_dout2 (.OUT1(dout_pn[2]),
    .VSS(VSS),
    .IN1(net121),
    .VDD(VDD));
 INVR05 u_drv_dout3 (.OUT1(dout_pn[3]),
    .VSS(VSS),
    .IN1(net119),
    .VDD(VDD));
 INVR05 u_drv_halt (.OUT1(halt_pn),
    .VSS(VSS),
    .IN1(halt),
    .VDD(VDD));
 INVR05 u_drv_rd (.OUT1(rd_pn),
    .VSS(VSS),
    .IN1(net17),
    .VDD(VDD));
 INVR05 u_drv_we (.OUT1(we_pn),
    .VSS(VSS),
    .IN1(\u_cpu.we ),
    .VDD(VDD));
 CDRI01 fanout1 (.Q(net1),
    .IN1(net3));
 CDRI01 fanout2 (.Q(net2),
    .IN1(net3));
 CDRI01 fanout3 (.Q(net3),
    .IN1(net4));
 CDRI01 fanout4 (.Q(net4),
    .IN1(net7));
 CDRI01 fanout5 (.Q(net5),
    .IN1(net7));
 CDRI01 fanout6 (.Q(net6),
    .IN1(net9));
 CDRI01 fanout7 (.Q(net7),
    .IN1(net8));
 CDRI01 max_cap8 (.Q(net8),
    .IN1(net9));
 CDRI01 wire9 (.Q(net9),
    .IN1(_046_));
 CDRI01 wire10 (.Q(net10),
    .IN1(_030_));
 CDRI01 wire11 (.Q(net11),
    .IN1(_027_));
 CDRI01 fanout12 (.Q(net12),
    .IN1(_124_));
 CDRI01 fanout13 (.Q(net13),
    .IN1(_124_));
 CDRI01 wire14 (.Q(net14),
    .IN1(_022_));
 CDRI01 wire15 (.Q(net15),
    .IN1(_130_));
 CDRI01 wire16 (.Q(net16),
    .IN1(_125_));
 CDRI01 wire17 (.Q(net17),
    .IN1(net18));
 CDRI01 wire18 (.Q(net18),
    .IN1(rd));
 CDRI01 max_cap19 (.Q(net19),
    .IN1(net20));
 CDRI01 wire20 (.Q(net20),
    .IN1(addr[4]));
 CDRI01 wire21 (.Q(net21),
    .IN1(net23));
 CDRI01 max_cap22 (.Q(net22),
    .IN1(net23));
 CDRI01 wire23 (.Q(net23),
    .IN1(addr[3]));
 CDRI01 fanout24 (.Q(net24),
    .IN1(net27));
 CDRI01 fanout25 (.Q(net25),
    .IN1(net26));
 CDRI01 max_cap26 (.Q(net26),
    .IN1(net27));
 CDRI01 wire27 (.Q(net27),
    .IN1(_075_));
 CDRI01 fanout28 (.Q(net28),
    .IN1(net32));
 CDRI01 fanout29 (.Q(net29),
    .IN1(net30));
 CDRI01 wire30 (.Q(net30),
    .IN1(net31));
 CDRI01 max_cap31 (.Q(net31),
    .IN1(net32));
 CDRI01 wire32 (.Q(net32),
    .IN1(_060_));
 CDRI01 fanout33 (.Q(net33),
    .IN1(net36));
 CDRI01 fanout34 (.Q(net34),
    .IN1(net35));
 CDRI01 max_cap35 (.Q(net35),
    .IN1(net36));
 CDRI01 wire36 (.Q(net36),
    .IN1(_048_));
 CDRI01 fanout37 (.Q(net37),
    .IN1(net40));
 CDRI01 fanout38 (.Q(net38),
    .IN1(net39));
 CDRI01 load_slew39 (.Q(net39),
    .IN1(net40));
 CDRI01 wire40 (.Q(net40),
    .IN1(_047_));
 CDRI01 wire41 (.Q(net41),
    .IN1(_129_));
 CDRI01 max_cap42 (.Q(net42),
    .IN1(_118_));
 CDRI01 fanout43 (.Q(net43),
    .IN1(net46));
 CDRI01 fanout44 (.Q(net44),
    .IN1(net46));
 CDRI01 fanout45 (.Q(net45),
    .IN1(net50));
 CDRI01 fanout46 (.Q(net46),
    .IN1(net50));
 CDRI01 fanout47 (.Q(net47),
    .IN1(net49));
 CDRI01 fanout48 (.Q(net48),
    .IN1(net49));
 CDRI01 fanout49 (.Q(net49),
    .IN1(net51));
 CDRI01 fanout50 (.Q(net50),
    .IN1(net52));
 CDRI01 fanout51 (.Q(net51),
    .IN1(net52));
 CDRI01 fanout52 (.Q(net52),
    .IN1(net55));
 CDRI01 fanout53 (.Q(net53),
    .IN1(net54));
 CDRI01 load_slew54 (.Q(net54),
    .IN1(net55));
 CDRI01 wire55 (.Q(net55),
    .IN1(_116_));
 CDRI01 fanout56 (.Q(net56),
    .IN1(net58));
 CDRI01 fanout57 (.Q(net57),
    .IN1(net58));
 CDRI01 fanout58 (.Q(net58),
    .IN1(net60));
 CDRI01 fanout59 (.Q(net59),
    .IN1(net60));
 CDRI01 fanout60 (.Q(net60),
    .IN1(net61));
 CDRI01 fanout61 (.Q(net61),
    .IN1(net72));
 CDRI01 fanout62 (.Q(net62),
    .IN1(net72));
 CDRI01 fanout63 (.Q(net63),
    .IN1(net65));
 CDRI01 fanout64 (.Q(net64),
    .IN1(net65));
 CDRI01 fanout65 (.Q(net65),
    .IN1(net66));
 CDRI01 fanout66 (.Q(net66),
    .IN1(net69));
 CDRI01 fanout67 (.Q(net67),
    .IN1(net68));
 CDRI01 fanout68 (.Q(net68),
    .IN1(net70));
 CDRI01 fanout69 (.Q(net69),
    .IN1(net70));
 CDRI01 fanout70 (.Q(net70),
    .IN1(net73));
 CDRI01 fanout71 (.Q(net71),
    .IN1(net73));
 CDRI01 fanout72 (.Q(net72),
    .IN1(_111_));
 CDRI01 fanout73 (.Q(net73),
    .IN1(net74));
 CDRI01 max_cap74 (.Q(net74),
    .IN1(_111_));
 CDRI01 fanout75 (.Q(net75),
    .IN1(_070_));
 CDRI01 wire76 (.Q(net76),
    .IN1(_052_));
 CDRI01 fanout77 (.Q(net77),
    .IN1(net80));
 CDRI01 fanout78 (.Q(net78),
    .IN1(net79));
 CDRI01 max_cap79 (.Q(net79),
    .IN1(net80));
 CDRI01 wire80 (.Q(net80),
    .IN1(_128_));
 CDRI01 wire81 (.Q(net81),
    .IN1(_109_));
 CDRI01 wire82 (.Q(net82),
    .IN1(_108_));
 CDRI01 fanout83 (.Q(net83),
    .IN1(\u_cpu.ir [7]));
 CDRI01 max_cap84 (.Q(net84),
    .IN1(net83));
 CDRI01 fanout85 (.Q(net85),
    .IN1(\u_cpu.ir [7]));
 CDRI01 fanout86 (.Q(net86),
    .IN1(net93));
 CDRI01 fanout87 (.Q(net87),
    .IN1(net93));
 CDRI01 max_cap88 (.Q(net88),
    .IN1(net87));
 CDRI01 fanout89 (.Q(net89),
    .IN1(net91));
 CDRI01 max_cap90 (.Q(net90),
    .IN1(net89));
 CDRI01 fanout91 (.Q(net91),
    .IN1(net92));
 CDRI01 fanout92 (.Q(net92),
    .IN1(\u_cpu.ir [6]));
 CDRI01 max_cap93 (.Q(net93),
    .IN1(net92));
 CDRI01 fanout94 (.Q(net94),
    .IN1(net95));
 CDRI01 fanout95 (.Q(net95),
    .IN1(\u_cpu.ir [5]));
 CDRI01 fanout96 (.Q(net96),
    .IN1(\u_cpu.ir [5]));
 CDRI01 max_cap97 (.Q(net97),
    .IN1(net96));
 CDRI01 wire98 (.Q(net98),
    .IN1(\u_cpu.ir [4]));
 CDRI01 wire99 (.Q(net99),
    .IN1(net100));
 CDRI01 load_slew100 (.Q(net100),
    .IN1(\u_cpu.ir [4]));
 CDRI01 wire101 (.Q(net101),
    .IN1(\u_cpu.ir [3]));
 CDRI01 wire102 (.Q(net102),
    .IN1(net103));
 CDRI01 load_slew103 (.Q(net103),
    .IN1(\u_cpu.ir [3]));
 CDRI01 wire104 (.Q(net104),
    .IN1(\u_cpu.ir [2]));
 CDRI01 wire105 (.Q(net105),
    .IN1(net107));
 CDRI01 wire106 (.Q(net106),
    .IN1(net107));
 CDRI01 load_slew107 (.Q(net107),
    .IN1(net108));
 CDRI01 load_slew108 (.Q(net108),
    .IN1(\u_cpu.ir [2]));
 CDRI01 wire109 (.Q(net109),
    .IN1(net111));
 CDRI01 max_cap110 (.Q(net110),
    .IN1(net111));
 CDRI01 load_slew111 (.Q(net111),
    .IN1(net113));
 CDRI01 wire112 (.Q(net112),
    .IN1(\u_cpu.ir [1]));
 CDRI01 load_slew113 (.Q(net113),
    .IN1(\u_cpu.ir [1]));
 CDRI01 wire114 (.Q(net114),
    .IN1(net117));
 CDRI01 max_cap115 (.Q(net115),
    .IN1(net117));
 CDRI01 max_cap116 (.Q(net116),
    .IN1(net118));
 CDRI01 max_cap117 (.Q(net117),
    .IN1(net118));
 CDRI01 wire118 (.Q(net118),
    .IN1(\u_cpu.ir [0]));
 CDRI01 fanout119 (.Q(net119),
    .IN1(dout[3]));
 CDRI01 fanout120 (.Q(net120),
    .IN1(net121));
 CDRI01 fanout121 (.Q(net121),
    .IN1(dout[2]));
 CDRI01 fanout122 (.Q(net122),
    .IN1(dout[1]));
 CDRI01 fanout123 (.Q(net123),
    .IN1(dout[1]));
 CDRI01 max_cap124 (.Q(net124),
    .IN1(net126));
 CDRI01 max_cap125 (.Q(net125),
    .IN1(net126));
 CDRI01 wire126 (.Q(net126),
    .IN1(\u_cpu.pc [4]));
 CDRI01 fanout127 (.Q(net127),
    .IN1(\u_cpu.pc [3]));
 CDRI01 max_cap128 (.Q(net128),
    .IN1(net127));
 CDRI01 max_cap129 (.Q(net129),
    .IN1(net127));
 CDRI01 fanout130 (.Q(net130),
    .IN1(net132));
 CDRI01 max_cap131 (.Q(net131),
    .IN1(net130));
 CDRI01 fanout132 (.Q(net132),
    .IN1(\u_cpu.pc [2]));
 CDRI01 fanout133 (.Q(net133),
    .IN1(\u_cpu.pc [1]));
 CDRI01 max_cap134 (.Q(net134),
    .IN1(net135));
 CDRI01 wire135 (.Q(net135),
    .IN1(net133));
 CDRI01 wire136 (.Q(net136),
    .IN1(_001_));
 CDRI01 fanout137 (.Q(net137),
    .IN1(\u_cpu.pc [0]));
 CDRI01 max_cap138 (.Q(net138),
    .IN1(net139));
 CDRI01 wire139 (.Q(net139),
    .IN1(net137));
 CDRI01 fanout140 (.Q(net140),
    .IN1(\u_cpu.pc [0]));
 CDRI01 clkbuf_0_clk (.Q(clknet_0_clk),
    .IN1(clk));
 CDRI01 clkbuf_1_0__f_clk (.Q(clknet_1_0__leaf_clk),
    .IN1(clknet_0_clk));
 CDRI01 clkbuf_1_1__f_clk (.Q(clknet_1_1__leaf_clk),
    .IN1(clknet_0_clk));
endmodule
