unit UFiltrosEMSA;

interface

uses
  SysUtils, Dialogs,Complex;
  Const Alto_de_Mod_Hj = 200;
type

  TFiltros = class
  private
//frequencia de amostragem
    _NotchBanda                                        : integer;
//per?odo de amostragem
    _FreqAm, _Periodo_Am                                                 : double;
//frequencias de corte
    _fr_corte_PA, _fr_corte_PB, _fr_corte_CT, _fr_corte_Nt,_Q_Nt: double;
//indices do PB
    _a0PB, _a1PB, _a2PB, _b1PB, _b2PB                           : double;
//indices do PA
    _a0PA, _a1PA, _a2PA, _b1PA, _b2PA                           : double;
//indices do Nt
    _a0NT, _a1NT, _a2NT, _b1NT, _b2NT                           : double;
    procedure CalculaIndices;
    procedure FiltraPA(var vetor: array of smallint; qtdAm: smallint);overload;
    procedure FiltraPB(var vetor: array of smallint; qtdAm: smallint);overload;
    procedure FiltraNT(var vetor: array of smallint; qtdAm: smallint);overload;
    procedure FiltraPA(var vetor: array of double; qtdAm: smallint);overload;
    procedure FiltraPB(var vetor: array of double; qtdAm: smallint);overload;
    procedure FiltraNT(var vetor: array of double; qtdAm: smallint);overload;
    Procedure CalcMod_Hj( osPolos,osZeros: Array of Tcomplex);
  public
    Mod_Hj              : array[0..Alto_de_Mod_Hj] of single;
    property fr_corte_PA: double read _fr_corte_PA;
    property fr_corte_PB: double read _fr_corte_PB;
    property fr_corte_CT: double read _fr_corte_CT;
    property fr_corte_Nt: double read _fr_corte_Nt;
    property Q_Nt: double read _Q_Nt;
    property NotchBanda : integer read _NotchBanda;
    constructor Create(FreqAm: Double; fcPA, fcPB, fcCT, fcNt, QNt: double; Notch_ou_Banda: integer);
    procedure Altera_fc(fcPA, fcPB, fcCT, fcNt,QNt: double; Notch_ou_Banda: integer);
    procedure Filtra(var vetor: array of smallint; qtdAm: smallint);overload;
    procedure Filtra(var vetor: array of double; qtdAm: smallint);overload;
    function TemFiltro: boolean;
  end;

implementation

uses Math;
var
(*  _TabelaPA_a: array[0..1,1..100] of single = ((0.98895, 0.97803, 0.96723, 0.95654,
  0.94598, 0.93553, 0.92519, 0.91497, 0.90486, 0.89486, 0.88497, 0.87518, 0.8655 ,
  0.85593, 0.84646, 0.83709, 0.82782, 0.81865, 0.80957, 0.80059, 0.79171, 0.78291,
  0.77421, 0.7656 , 0.75708, 0.74864, 0.74029, 0.73202, 0.72384, 0.71574, 0.70772,
  0.69977, 0.69191, 0.68412, 0.67641, 0.66877, 0.66121, 0.65372, 0.6463 , 0.63895,
  0.63166, 0.62445, 0.6173 , 0.61022, 0.6032 , 0.59624, 0.58935, 0.58252, 0.57575,
  0.56904, 0.56238, 0.55579, 0.54925, 0.54277, 0.53634, 0.52997, 0.52365, 0.51738,
  0.51117, 0.505  , 0.49889, 0.49282, 0.48681, 0.48084, 0.47492, 0.46904, 0.46322,
  0.45743, 0.45169, 0.446  , 0.44035, 0.43474, 0.42917, 0.42365, 0.41816, 0.41272,
  0.40732, 0.40195, 0.39662, 0.39134, 0.38609, 0.38087, 0.3757 , 0.37055, 0.36545,
  0.36038, 0.35535, 0.35035, 0.34538, 0.34045, 0.33555, 0.33068, 0.32585, 0.32105,
  0.31628, 0.31154, 0.30683, 0.30215, 0.29751, 0.29289),
  (-1.9779, -1.9561 , -1.9345 , -1.9131 , -1.892  , -1.8711 , -1.8504 , -1.8299 , -1.8097 ,
  -1.7897 , -1.7699 , -1.7504 , -1.731  , -1.7119 , -1.6929 , -1.6742 , -1.6556 , -1.6373 ,
  -1.6191 , -1.6012 , -1.5834 , -1.5658 , -1.5484 , -1.5312 , -1.5142 , -1.4973 , -1.4806 ,
  -1.464  , -1.4477 , -1.4315 , -1.4154 , -1.3995 , -1.3838 , -1.3682 , -1.3528 , -1.3375 ,
  -1.3224 , -1.3074 , -1.2926 , -1.2779 , -1.2633 , -1.2489 , -1.2346 , -1.2204 , -1.2064 ,
  -1.1925 , -1.1787 , -1.165  , -1.1515 , -1.1381 , -1.1248 , -1.1116 , -1.0985 , -1.0855 ,
  -1.0727 , -1.0599 , -1.0473 , -1.0348 , -1.0223 , -1.01   ,-0.99777 , -0.98564, -0.97361,
  -0.96168, -0.94984, -0.93809, -0.92643, -0.91486, -0.90339, -0.892  , -0.8807 , -0.86948,
  -0.85835, -0.8473 , -0.83633, -0.82544, -0.81463, -0.8039 , -0.79325, -0.78267, -0.77217,
  -0.76174, -0.75139, -0.74111, -0.7309 , -0.72076, -0.71069, -0.70069, -0.69076, -0.6809 ,
  -0.6711 , -0.66137, -0.6517 , -0.64209, -0.63255, -0.62308, -0.61366, -0.60431, -0.59502,
  -0.58579));

  _TabelaPA_b: array[0..1,1..100] of single = ((   1.9778, 1.9556, 1.9334, 1.9112 , 1.889  ,
  1.8669, 1.8448, 1.8227, 1.8006, 1.7786, 1.7567, 1.7347, 1.7128, 1.691 , 1.6692 , 1.6475 ,
  1.6258, 1.6041, 1.5825, 1.561 , 1.5395, 1.5181, 1.4968, 1.4755, 1.4542, 1.4331 , 1.412  ,
  1.3909, 1.3699, 1.349 , 1.3281, 1.3073, 1.2865, 1.2658, 1.2452, 1.2247, 1.2041 , 1.1837 ,
  1.1633, 1.143 , 1.1227, 1.1025, 1.0823, 1.0622, 1.0422, 1.0222, 1.0023, 0.98241, 0.96258,
  0.94281, 0.92309, 0.90342, 0.8838, 0.86423, 0.84471, 0.82523, 0.8058, 0.78642, 0.76708,
  0.74779, 0.72854, 0.70933, 0.69016, 0.67103, 0.65194, 0.63289, 0.61387, 0.59489, 0.57594,
  0.55703, 0.53815, 0.5193, 0.50049, 0.4817, 0.46294, 0.44421, 0.4255, 0.40682, 0.38816,
  0.36953, 0.35092, 0.33232, 0.31375, 0.2952, 0.27666, 0.25815, 0.23964, 0.22115, 0.20268,
  0.18421, 0.16576, 0.14732, 0.12888, 0.11046, 0.092038, 0.073624, 0.055214, 0.036808,
  0.018403, 4.58E-16),
  (-0.97803, -0.95654, -0.93553, -0.91498, -0.89487, -0.87521, -0.85599, -0.83718,
  -0.81879, -0.8008, -0.78321, -0.76601, -0.74918, -0.73273, -0.71663, -0.7009, -0.68551,
  -0.67046, -0.65574, -0.64135, -0.62728, -0.61352, -0.60007, -0.58692, -0.57406, -0.56149,
  -0.54921, -0.53719, -0.52546, -0.51398, -0.50277, -0.49181, -0.48111, -0.47065, -0.46043,
  -0.45045, -0.4407, -0.43118, -0.42188, -0.4128, -0.40394, -0.39529, -0.38685, -0.37862,
  -0.37059, -0.36275, -0.35511, -0.34767, -0.34041, -0.33333, -0.32644, -0.31973, -0.3132,
  -0.30684, -0.30065, -0.29464, -0.28879, -0.2831, -0.27758, -0.27221, -0.26701, -0.26196,
  -0.25707, -0.25232, -0.24773, -0.24329, -0.23899, -0.23484, -0.23083, -0.22697, -0.22324,
  -0.21965, -0.21621, -0.21289, -0.20972, -0.20667, -0.20376, -0.20098, -0.19833, -0.19582,
  -0.19343, -0.19116, -0.18903, -0.18702, -0.18514, -0.18338, -0.18174, -0.18023, -0.17884,
  -0.17758, -0.17643, -0.17541, -0.17451, -0.17373, -0.17307, -0.17253, -0.17211, -0.17181,
  -0.17163, -0.17157));
*)
  _TabelaPA_a: array[0..1,1..100] of single = (
( 0.99778102, 0.99556697, 0.99335783, 0.99115360, 0.98895425, 0.98675978, 0.98457018, 0.98238544, 0.98020554, 0.97803048, 
0.97586024, 0.97369481, 0.97153418, 0.96937834, 0.96722728, 0.96508099, 0.96293944, 0.96080264, 0.95867058, 0.95654323, 
0.95442058, 0.95230264, 0.95018937, 0.94808079, 0.94597686, 0.94387758, 0.94178293, 0.93969291, 0.93760751, 0.93552671, 
0.93345049, 0.93137886, 0.92931179, 0.92724927, 0.92519130, 0.92313786, 0.92108893, 0.91904451, 0.91700459, 0.91496914, 
0.91293817, 0.91091166, 0.90888959, 0.90687196, 0.90485875, 0.90284995, 0.90084554, 0.89884553, 0.89684989, 0.89485861, 
0.89287168, 0.89088909, 0.88891082, 0.88693687, 0.88496722, 0.88300186, 0.88104078, 0.87908397, 0.87713141, 0.87518309, 
0.87323901, 0.87129914, 0.86936347, 0.86743200, 0.86550472, 0.86358160, 0.86166264, 0.85974783, 0.85783716, 0.85593060, 
0.85402816, 0.85212981, 0.85023556, 0.84834537, 0.84645925, 0.84457719, 0.84269916, 0.84082516, 0.83895517, 0.83708919, 
0.83522720, 0.83336919, 0.83151515, 0.82966507, 0.82781894, 0.82597673, 0.82413845, 0.82230408, 0.82047361, 0.81864702, 
0.81682431, 0.81500546, 0.81319047, 0.81137932, 0.80957199, 0.80776849, 0.80596878, 0.80417288, 0.80238076, 0.80059240),
(-1.9955620, -1.9911339, -1.9867157, -1.9823072, -1.9779085, -1.9735196, -1.9691404, -1.9647709, -1.9604111, -1.9560610, 
-1.9517205, -1.9473896, -1.9430684, -1.9387567, -1.9344546, -1.9301620, -1.9258789, -1.9216053, -1.9173412, -1.9130865, 
-1.9088412, -1.9046053, -1.9003787, -1.8961616, -1.8919537, -1.8877552, -1.8835659, -1.8793858, -1.8752150, -1.8710534, 
-1.8669010, -1.8627577, -1.8586236, -1.8544985, -1.8503826, -1.8462757, -1.8421779, -1.8380890, -1.8340092, -1.8299383, 
-1.8258763, -1.8218233, -1.8177792, -1.8137439, -1.8097175, -1.8056999, -1.8016911, -1.7976911, -1.7936998, -1.7897172, 
-1.7857434, -1.7817782, -1.7778216, -1.7738737, -1.7699344, -1.7660037, -1.7620816, -1.7581679, -1.7542628, -1.7503662, 
-1.7464780, -1.7425983, -1.7387269, -1.7348640, -1.7310094, -1.7271632, -1.7233253, -1.7194957, -1.7156743, -1.7118612, 
-1.7080563, -1.7042596, -1.7004711, -1.6966907, -1.6929185, -1.6891544, -1.6853983, -1.6816503, -1.6779103, -1.6741784, 
-1.6704544, -1.6667384, -1.6630303, -1.6593301, -1.6556379, -1.6519535, -1.6482769, -1.6446082, -1.6409472, -1.6372940, 
-1.6336486, -1.6300109, -1.6263809, -1.6227586, -1.6191440, -1.6155370, -1.6119376, -1.6083458, -1.6047615, -1.6011848));

  _TabelaPA_b: array[0..1,1..100] of single = (
(-1.9955571, -1.9911143, -1.9866715, -1.9822289, -1.9777865, -1.9733442, -1.9689023, -1.9644606, -1.9600192, -1.9555782, 
-1.9511377, -1.9466975, -1.9422579, -1.9378188, -1.9333802, -1.9289423, -1.9245049, -1.9200683, -1.9156323, -1.9111971, 
-1.9067626, -1.9023289, -1.8978961, -1.8934641, -1.8890331, -1.8846029, -1.8801738, -1.8757456, -1.8713184, -1.8668923, 
-1.8624672, -1.8580433, -1.8536205, -1.8491989, -1.8447784, -1.8403592, -1.8359412, -1.8315245, -1.8271090, -1.8226949, 
-1.8182822, -1.8138708, -1.8094608, -1.8050522, -1.8006451, -1.7962394, -1.7918352, -1.7874325, -1.7830314, -1.7786318, 
-1.7742338, -1.7698373, -1.7654425, -1.7610494, -1.7566578, -1.7522680, -1.7478799, -1.7434934, -1.7391087, -1.7347258, 
-1.7303446, -1.7259652, -1.7215876, -1.7172118, -1.7128379, -1.7084658, -1.7040956, -1.6997273, -1.6953609, -1.6909964, 
-1.6866338, -1.6822732, -1.6779145, -1.6735578, -1.6692031, -1.6648505, -1.6604998, -1.6561511, -1.6518045, -1.6474600, 
-1.6431175, -1.6387771, -1.6344388, -1.6301026, -1.6257685, -1.6214365, -1.6171067, -1.6127790, -1.6084535, -1.6041302, 
-1.5998090, -1.5954900, -1.5911732, -1.5868587, -1.5825463, -1.5782362, -1.5739283, -1.5696226, -1.5653192, -1.5610181),
( 0.99556697, 0.99115360, 0.98675978, 0.98238545, 0.97803051, 0.97369487, 0.96937846, 0.96508117, 0.96080294, 0.95654368, 
0.95230329, 0.94808171, 0.94387883, 0.93969460, 0.93552890, 0.93138168, 0.92725284, 0.92314231, 0.91905000, 0.91497583, 
0.91091973, 0.90688161, 0.90286139, 0.89885899, 0.89487434, 0.89090736, 0.88695797, 0.88302609, 0.87911164, 0.87521455, 
0.87133474, 0.86747213, 0.86362666, 0.85979824, 0.85598679, 0.85219225, 0.84841454, 0.84465359, 0.84090931, 0.83718165, 
0.83347052, 0.82977586, 0.82609759, 0.82243563, 0.81878993, 0.81516040, 0.81154698, 0.80794959, 0.80436817, 0.80080265, 
0.79725295, 0.79371901, 0.79020076, 0.78669813, 0.78321105, 0.77973946, 0.77628328, 0.77284246, 0.76941692, 0.76600660, 
0.76261143, 0.75923135, 0.75586629, 0.75251618, 0.74918097, 0.74586058, 0.74255496, 0.73926403, 0.73598774, 0.73272603, 
0.72947883, 0.72624607, 0.72302770, 0.71982366, 0.71663387, 0.71345829, 0.71029685, 0.70714950, 0.70401616, 0.70089678, 
0.69779131, 0.69469967, 0.69162182, 0.68855769, 0.68550723, 0.68247038, 0.67944708, 0.67643727, 0.67344090, 0.67045791, 
0.66748824, 0.66453183, 0.66158864, 0.65865860, 0.65574166, 0.65283776, 0.64994686, 0.64706889, 0.64420380, 0.64135154));


  _TabelaNT_a: array[0..1, 1..100] of single = ((0, -39.541, -39.517, -39.483, -39.439,
  -39.385, -39.322, -39.249, -39.166, -39.074, -38.972, -3.886, -38.739, -38.608,
  -38.468, -38.318, -38.159, -3.799, -37.812, -37.624, -37.428, -37.222, -37.007, -36.783,
  -36.549, -36.307, -36.056, -35.796, -35.527, -35.249, -34.962, -34.667, -34.364, -34.052,
  -33.731, -33.402, -33.065, -3.272, -32.367, -32.005, -31.636, -31.259, -30.874, -30.482,
  -30.082, -29.675, -2.926, -28.838, -2.841, -27.974, -27.531, -27.081, -26.625, -26.162,
  -25.693, -25.217, -24.735, -24.247, -23.753, -23.253, -22.748, -22.236, -2.172, -21.198,
  -2.067, -20.138, -19.601, -19.058, -18.512, -1.796, -17.404, -16.844, -1.628, -15.711,
  -15.139, -14.563, -13.984, -13.401, -12.814, -12.225, -11.632, -11.037, -10.439, -0.98383,
  -0.92353, -0.86299, -0.80224, -0.74129, -0.68016, -0.61887, -0.55741, -0.49583, -0.43412,
  -0.3723, -0.31039, -0.2484, -0.18636, -0.12426, -0.062139, -5.83E-12),
  (0, 58.648, 5.86, 58.532, 58.446, 5.834, 58.215, 58.072, 5.791, 57.729, 5.753, 57.313,
  57.077, 56.825, 56.554, 56.267, 55.962, 55.641, 55.303, 5.495, 54.581, 54.197, 53.797,
  53.384, 52.956, 52.515, 5.206, 51.593, 51.113, 50.621, 50.119, 49.605, 49.081, 48.547,
  48.004, 47.452, 46.892, 46.324, 45.749, 45.167, 4.458, 43.987, 43.389, 42.787, 42.182,
  41.573, 40.962, 4.035, 39.736, 39.121, 38.507, 37.893, 3.728, 36.669, 36.061, 35.455,
  34.853, 34.255, 33.663, 33.075, 32.494, 31.919, 31.351, 30.791, 30.239, 29.695, 29.162,
  28.638, 28.124, 27.621, 27.129, 2.665, 26.182, 25.728, 25.286, 24.859, 24.445, 24.046,
  23.661, 23.292, 22.939, 22.602, 2.228, 21.976, 21.688, 21.418, 21.165, 2.093, 20.712,
  20.513, 20.333, 2.017, 20.027, 19.902, 19.797, 1.971, 19.643, 19.594, 19.565, 19.556));

  _TabelaNT_b: array[0..1, 1..100] of single = ((0, -39.107, -39.083, -39.049, -39.005,
  -38.952, -3.889, -38.818, -38.736, -38.644, -38.543, -38.433, -38.313, -38.184,
  -38.045, -37.897, -37.739, -37.572, -37.396, -37.211, -37.017, -36.813, -3.66, -36.378,
  -36.148, -35.908, -3.566, -35.402, -35.136, -34.862, -34.578, -34.286, -33.986, -33.677,
  -3.336, -33.035, -32.702, -3.236, -32.011, -31.654, -31.288, -30.916, -30.535, -30.147,
  -29.752, -29.349, -28.939, -28.522, -28.097, -27.666, -27.228, -26.784, -26.332, -25.875,
  -2.541, -2.494, -24.463, -23.981, -23.492, -22.998, -22.498, -21.992, -21.481, -20.965,
  -20.443, -19.917, -19.385, -18.849, -18.308, -17.763, -17.213, -16.659, -16.101, -15.539,
  -14.973, -14.403, -1.383, -13.253, -12.674, -12.091, -11.505, -10.916, -10.324, -0.97303,
  -0.91338, -0.85351, -0.79343, -0.73315, -0.67269, -0.61207, -0.55129, -0.49038, -0.42935,
  -0.36821, -0.30698, -0.24567, -0.18431, -0.1229, -0.061457, -2.40E-12),
  (0, 58.653, 58.605, 58.537, 58.451, 58.345, 5.822, 58.077, 57.915, 57.734, 57.535,
  57.318, 57.082, 56.829, 56.559, 56.271, 55.967, 55.646, 55.308, 54.955, 54.586, 54.201,
  53.802, 53.389, 52.961, 5.252, 52.065, 51.598, 51.118, 50.626, 50.123, 4.961, 49.086,
  48.552, 48.009, 47.457, 46.896, 46.329, 45.754, 45.172, 44.585, 43.992, 43.394, 42.792,
  42.187, 41.578, 40.967, 40.355, 39.741, 39.126, 38.511, 37.898, 37.285, 36.674, 36.065,
  3.546, 34.858, 3.426, 33.667, 3.308, 32.498, 31.924, 31.356, 30.795, 30.244, 2.97, 29.166,
  28.642, 28.129, 27.626, 27.134, 26.655, 26.187, 25.733, 25.291, 24.863, 2.445, 24.051,
  23.666, 23.297, 22.944, 22.606, 22.285, 21.981, 21.693, 21.423, 2.117, 20.935, 20.717,
  20.518, 20.337, 20.175, 20.032, 19.907, 19.801, 19.715, 19.647, 19.599, 1.957, 19.561));


{ TFiltros }

procedure TFiltros.Altera_fc(fcPA, fcPB, fcCT, fcNt,QNt: double; Notch_ou_Banda: integer);
begin
  _fr_corte_PA:= fcPA;
  _fr_corte_PB:= fcPB;
  _fr_corte_CT:= fcCT;
  _fr_corte_Nt:= fcNt;
  _Q_Nt := QNt;
  _NotchBanda := Notch_ou_Banda;
//recalcula os indices que ser?o usados para filtrar
  CalculaIndices;
end;

procedure TFiltros.CalculaIndices;
const
  constante_corte_3DB = 1.18;//2.0775;//1.2465;
var
  wdPB, waPB: double;
  indice: smallint;
  c, Angulo:double;
  re,im : Extended;
  j,k:integer;
  caux : Tcomplex;
  VetC,VetC2 : Array [1..4] of Tcomplex;
  Polos,Zeros: Array [1..2] of Tcomplex;
begin
/////////////---PASSA BAIXAS---//////////////////////////////////////////////////
  c := 4*_fr_corte_PB / _FreqAm;
  _a0PB:= sqr(c) / (1 + (sqrt(2) * c) + sqr(c));
  _a1PB:= 2*_a0PB;
  _a2PB:= _a0PB;
  _b1PB:= -2*(sqr(c)-1) / (1 + (sqrt(2) * c) + sqr(c));
  _b2PB:= -(1 - (sqrt(2) * c) + sqr(C))/ (1 + (sqrt(2) * c) + sqr(c));

//  indice:= round((_fr_corte_PA*200/_FreqAm)*2);
  indice:= round(_fr_corte_PA*2000/_FreqAm);
  if (indice < 1) or (indice > 100) then
  begin
    _a0PA:= 0;
    _a1PA:= 0;
    _a2PA:= 0;
    _b1PA:= 0;
    _b2PA:= 0;
  end
  else
  begin
    _a0PA:= _TabelaPA_a[0][indice];
    _a1PA:= _TabelaPA_a[1][indice];
    _a2PA:= _a0PA;
    _b1PA:= -_TabelaPA_b[0][indice];
    _b2PA:= -_TabelaPA_b[1][indice];
  end;

/////////////---NOTCH---/////////////////////////////////////////////////////////
  indice:= round((_fr_corte_NT*200/_FreqAm)*2);
  _a0NT:= 1;
  if indice = 0 then
  begin
    _a0NT:= 0;
   _a1NT:= 0;
    _a2NT:= 0;
    _b1NT:= 0;
    _b2NT:= 0;
  end
  else
  begin
    Angulo := 360 *  _fr_corte_NT / _FreqAm;

    for j := 1 to 2 do
    begin
      Zeros[j] := TComplex.Create;
      Polos[j] := TComplex.Create;
    end;

    re:= 1*cos(pi*Angulo/180);
    im:= 1*sin(pi*Angulo/180);
    Zeros[1].Re := re;
    Zeros[1].Im := im;
    Zeros[2].Re := re;
    Zeros[2].Im := -im;
//    Fator := 0.97;
    re:= (_Q_Nt/100)*cos(pi*Angulo/180);
    im:= (_Q_Nt/100)*sin(pi*Angulo/180);
    Polos[1].Re := re;
    Polos[1].Im := im;
    Polos[2].Re := re;
    Polos[2].Im := -im;
//POLOS
    caux := TComplex.Create;
    for j := 1 to (3) do
    begin
      VetC[j] := TComplex.Create;
      VetC2[j] := TComplex.Create;
    end;
    VetC[1].Re := 1;//? isso mesmo
    for j := 1 to 2 do
    begin
      for k := 1 to j do
      begin
        caux.Assign(polos[j]);//e[j]
        caux.Multiply(VetC[k]);//e[j]*c[k]
        caux.Subtract(VetC[1+k]);//-c[k+1]+e[j]*c[k]
        caux.Negate;// c[k+1]-e[j]*c[k]
        VetC2[1+k].Assign(caux);
      end;
      for k := 1 to j do
        VetC[1+k].Assign(VetC2[1+k])
    end;//for j
    _b1NT:= -VetC[2].Re;
    _b2NT:= -VetC[3].Re;
    caux.Free;
    for j := 1 to (3) do
    begin
      VetC[j].Free;
      VetC2[j].Free;
    end;
//ZEROS
    caux := TComplex.Create;
    for j := 1 to (3) do
    begin
      VetC[j] := TComplex.Create;
      VetC2[j] := TComplex.Create;
    end;
    VetC[1].Re := 1;//? isso mesmo
    for j := 1 to 2 do
    begin
      for k := 1 to j do
      begin
        caux.Assign(Zeros[j]);//e[j]
        caux.Multiply(VetC[k]);//e[j]*c[k]
        caux.Subtract(VetC[1+k]);//-c[k+1]+e[j]*c[k]
        caux.Negate;// c[k+1]-e[j]*c[k]
        VetC2[1+k].Assign(caux);
      end;
      for k := 1 to j do
        VetC[1+k].Assign(VetC2[1+k])
    end;//for j
    _a0NT:= VetC[1].Re;
    _a1NT:= VetC[2].Re;
    _a2NT:= VetC[3].Re;
    caux.Free;
    for j := 1 to (3) do
    begin
      VetC[j].Free;
      VetC2[j].Free;
    end;
    CalcMod_Hj(  Polos,Zeros);
    for j := 1 to 2 do
    begin
      Zeros[j].Free;
      Polos[j].Free;
    end;
  end; // do else do if indice = 0 then
end;//procedure TFiltros.CalculaIndices;

procedure TFiltros.CalcMod_Hj( osPolos,osZeros: Array of Tcomplex);
var
  i : integer;
  caux, jw : TComplex;
//  ModHj:double;
begin
  i := high(osPolos);
  caux:= TComplex.CreatePolar(0,0);
  //caux.Assign(osPolos[1]);
  jw:= TComplex.CreatePolar(0,0);
  for i := 0 to Pred(Alto_de_Mod_Hj) do
  begin
    jw.Re := 1*cos(pi*i/200);
    jw.Im := 1*sin(pi*i/200);
    caux.Assign(jw);
    caux.Subtract(osPolos[0]);
    Mod_Hj[i] := 1/Sqrt(Sqr(caux.Re)+Sqr(caux.Im));
    caux.Assign(jw);
    caux.Subtract(osPolos[1]);
    Mod_Hj[i] := Mod_Hj[i] / Sqrt(Sqr(caux.Re)+Sqr(caux.Im));

    caux.Assign(jw);
    caux.Subtract(osZeros[0]);
    Mod_Hj[i] := Mod_Hj[i] * Sqrt(Sqr(caux.Re)+Sqr(caux.Im));
    caux.Assign(jw);
    caux.Subtract(osZeros[1]);
    Mod_Hj[i] := Mod_Hj[i] *  Sqrt(Sqr(caux.Re)+Sqr(caux.Im));
  end;
  jw.Free;
  caux.Free;
end;//procedure TFiltros.CalcMod_Hj;

constructor TFiltros.Create(FreqAm: Double; fcPA, fcPB, fcCT,
  fcNt,QNt: double; Notch_ou_Banda: integer);
begin
  _FreqAm:= FreqAm;
  _Periodo_Am:= 1/_FreqAm;
  Altera_fc(fcPA, fcPB, fcCT, fcNt,QNt,Notch_ou_Banda);
//calcula os indices que ser?o usados para filtrar
//  CalculaIndices;   // essa rotina j? ? chamada de dentro da Altera_fc
end;

procedure TFiltros.Filtra(var vetor: array of smallint;qtdAm: smallint);
begin
  if _fr_corte_Nt > 0 then
    filtraNT(vetor, qtdAm);
  if _fr_corte_PB > 0 then
    filtraPB(vetor, qtdAm);
  if _fr_corte_PA > 0 then
    filtraPA(vetor, qtdAm);
//  if _fr_corte_Nt > 0 then
//    filtraNT(vetor, qtdAm);
end;

procedure TFiltros.FiltraPA(var vetor: array of smallint; qtdAm: smallint);
var
  iAm, um4 , tres4: integer;
//vetores auxiliares para calculo
  _vetAux, _vetAux2, vetorD: array of double;
begin   {$R+}
  SetLength(_vetAux, 2*qtdAm);
  SetLength(_vetAux2,2* qtdAm);
  SetLength(vetorD, 2*qtdAm); //dobro do tamanho
  um4 := qtdam div 2; tres4 := 2*qtdam - um4;
  for iAm:=0 to pred(2*qtdAm) do
  begin
    _vetAux[iAm]:= 0;
    _vetAux2[iAm]:= 0;
  end;
  for iAm:=um4 to pred(tres4 - 1) do
    vetorD[iAm] := vetor[iAm - um4];//iAm* Sign((iAm mod 20)-10);//
  for iAm:=0 to pred(um4) do
    vetorD[iAm] := vetor[um4-iAm];//iAm* Sign((iAm mod 20)-10);//
  for iAm:= tres4 to pred(2*qtdam) do
    vetorD[iAm] := vetor[pred(2*qtdam) - iAm + um4];//iAm* Sign((iAm mod 20)-10);//
{
  for iAm:=um4 to pred(tres4) do
    vetorD[iAm] := vetor[iAm - um4];//iAm* Sign((iAm mod 20)-10);//
  for iAm:=0 to pred(um4) do
    vetorD[iAm] := vetor[um4-iAm];//iAm* Sign((iAm mod 20)-10);//
  for iAm:= tres4 to pred(2*qtdam) do
    vetorD[iAm] := vetor[pred(2*qtdam) - iAm + um4];//iAm* Sign((iAm mod 20)-10);//
}
  _vetAux[0]:= 0; _vetAux[1]:= 0;
//calcula invertido
    for iAm:= 2 to pred(2*qtdAm) do
    begin
      _vetAux[iAm]:= (_a0PA*vetorD[iAm] + _a1PA*vetorD[iAm-1] + _a2PA*vetorD[iAm-2] +
                    _b1PA*_vetAux[iAm-1] + _b2PA*_vetAux[iAm-2]);
      _vetAux2[pred(2*qtdAm)-iAm] := _vetAux[iAm];
    end;
  _vetAux[0]:= _vetAux[2]/3; _vetAux[1]:= 2*_vetAux[2]/3;
//calcula desinvertendo
{  for iAm:= 2 to pred(qtdAm) do
  begin
    _vetAux[pred(qtdAm)-iAm]:= _a0PB*_vetAux2[iAm]  + _a1PB*_vetAux2[iAm-1] + _a2PB*_vetAux2[iAm-2] +
                   _b1PB*_vetAux[pred(qtdAm)-iAm+1] + _b2PB*_vetAux[pred(qtdAm)-iAm+2];
  end;
}
    for iAm:= 2 to pred(2*qtdAm) do
    begin
      _vetAux[pred(2*qtdAm)-iAm]:= _a0PA*_vetAux2[iAm] + _a1PA*_vetAux2[iAm-1] + _a2PA*_vetAux2[iAm-2] +
                    _b1PA*_vetAux[pred(2*qtdAm)-iAm+1] + _b2PA*_vetAux[pred(2*qtdAm)-iAm+2];
    end;
{    for iAm:= 2 to pred(2*qtdAm) do
    begin
      _vetAux[iAm]:= _a0PA*_vetAux2[iAm] + _a1PA*_vetAux2[iAm-1] + _a2PA*_vetAux2[iAm-2] +
                    _b1PA*_vetAux[iAm-1] + _b2PA*_vetAux[iAm-2];
    end;
}
//ajusta amplitude...
    for iAm:= 2 to pred(qtdAm) do
      vetor[iAm]:= round(_vetAux[um4+iAm]);  {$R-}
//      vetor[iAm]:= round(_vetAux[pred(qtdAm)+iAm]);  {$R-}
end; // procedure TFiltros.FiltraPA(var vetor: array of smallint; qtdAm: smallint);

procedure TFiltros.FiltraPB(var vetor: array of smallint; qtdAm: smallint);
var
  iAm: integer;
//vetores auxiliares para calculo
  _vetAux, _vetAux2: array of double;
begin
//{$R+}
  SetLength(_vetAux, qtdAm);
  SetLength(_vetAux2, qtdAm);
  _vetAux[0]:= 0; _vetAux[1]:= 0;
  vetor[0]:= 0; vetor[1]:= 0;
//calcula invertido
  for iAm:= 2 to pred(qtdAm) do
  begin
    _vetAux[iAm]:= _a0PB*vetor[iAm]     + _a1PB*vetor[iAm-1] + _a2PB*vetor[iAm-2] +
                   _b1PB*_vetAux[iAm-1] + _b2PB*_vetAux[iAm-2];
    _vetAux2[pred(qtdAm)-iAm] := _vetAux[iAm];
  end;
//calcula desinvertendo
  for iAm:= 2 to pred(qtdAm) do
  begin
    _vetAux[pred(qtdAm)-iAm]:= _a0PB*_vetAux2[iAm]  + _a1PB*_vetAux2[iAm-1] + _a2PB*_vetAux2[iAm-2] +
                   _b1PB*_vetAux[pred(qtdAm)-iAm+1] + _b2PB*_vetAux[pred(qtdAm)-iAm+2];
  end;
//ajusta amplitude...
//  if _fr_corte_PA = 0 then
    for iAm:= 2 to pred(qtdAm) do
      vetor[iAm]:= round(1*_vetAux[iAm])
//  else
//    for iAm:= 2 to pred(qtdAm) do
//      vetor[pred(qtdAm)-iAm]:= round(1*_vetAux[iAm]);
//{$R-}

end;//procedure TFiltros.FiltraPB(var vetor: array of smallint; qtdAm: smallint);

procedure TFiltros.Filtra(var vetor: array of double; qtdAm: smallint);
var
  iAm: integer;
//vetores auxiliares para calculo
  _vetAux, _vetAux2: array of double;
begin
  if _fr_corte_Nt > 0 then
    filtraNT(vetor, qtdAm);
  if _fr_corte_PB > 0 then
    filtraPB(vetor, qtdAm);
  if _fr_corte_PA > 0 then
    filtraPA(vetor, qtdAm);
end;

procedure TFiltros.FiltraNT(var vetor: array of double; qtdAm: smallint);
var
  iAm: integer;
//vetores auxiliares para calculo
  vetAux, vetAux2: array of double;
begin
//{$R+}
  SetLength(vetAux, qtdAm);
  SetLength(vetAux2, qtdAm);
  vetAux[0]:= 0; vetAux[1]:= 0;
//  vetor[0]:= 0; vetor[1]:= 0;
//calcula invertido
  for iAm:= 2 to pred(qtdAm) do
  begin
    vetAux[iAm]:= _a0NT*vetor[iAm]     + _a1NT*vetor[iAm-1] + _a2NT*vetor[iAm-2] +
                   _b1NT*vetAux[iAm-1] + _b2NT*vetAux[iAm-2];
    vetAux2[pred(qtdAm)-iAm] := vetAux[iAm];
  end;
//calcula desinvertendo
  for iAm:= 2 to pred(qtdAm) do
  begin
//    vetAux[iAm]:= _a0NT*vetAux2[iAm]  + _a1NT*vetAux2[iAm-1] + _a2NT*vetAux2[iAm-2] +
//    vetAux[iAm]:= _a0NT*vetAux2[pred(qtdAm)-iAm]  + _a1NT*vetAux2[pred(qtdAm)-iAm+1] + _a2NT*vetAux2[pred(qtdAm)-iAm+2] +
//                   _b1NT*vetAux[iAm-1] + _b2NT*vetAux[iAm-2];
    vetAux[pred(qtdAm)-iAm]:= _a0NT*vetAux2[iAm]  + _a1NT*vetAux2[iAm-1] + _a2NT*vetAux2[iAm-2] +
                   _b1NT*vetAux[pred(qtdAm)-iAm+1] + _b2NT*vetAux[pred(qtdAm)-iAm+2];
  end;
//ajusta amplitude...
  if _NotchBanda = 1 then  // ? para passa banda
    for iAm:= 0 to pred(qtdAm) do
      vetAux2[iAm]:= vetor[iAm]
  else // ? para Notch
    for iAm:= 0 to pred(qtdAm) do
      vetAux2[iAm]:= 0;

  for iAm:= 2 to pred(qtdAm) do
    vetor[iAm]:= round((vetAux[iAm] / sqr(Mod_Hj[Alto_de_Mod_Hj-2]))-vetAux2[iAm]) // Normaliza ***************
//{$R-}
end;//procedure TFiltros.FiltraNT(var vetor: array of ; qtdAm: smallint);

procedure TFiltros.FiltraNT(var vetor: array of smallint; qtdAm: smallint);
var
  iAm: integer;
//vetores auxiliares para calculo
  vetAux, vetAux2: array of double;
begin
//{$R+}
  SetLength(vetAux, qtdAm);
  SetLength(vetAux2, qtdAm);
  vetAux[0]:= 0; vetAux[1]:= 0;
//  vetor[0]:= 0; vetor[1]:= 0;
//calcula invertido
  for iAm:= 2 to pred(qtdAm) do
  begin
    vetAux[iAm]:= _a0NT*vetor[iAm]     + _a1NT*vetor[iAm-1] + _a2NT*vetor[iAm-2] +
                   _b1NT*vetAux[iAm-1] + _b2NT*vetAux[iAm-2];
    vetAux2[pred(qtdAm)-iAm] := vetAux[iAm];
  end;
//calcula desinvertendo
  for iAm:= 2 to pred(qtdAm) do
  begin
//    vetAux[iAm]:= _a0NT*vetAux2[iAm]  + _a1NT*vetAux2[iAm-1] + _a2NT*vetAux2[iAm-2] +
//    vetAux[iAm]:= _a0NT*vetAux2[pred(qtdAm)-iAm]  + _a1NT*vetAux2[pred(qtdAm)-iAm+1] + _a2NT*vetAux2[pred(qtdAm)-iAm+2] +
//                   _b1NT*vetAux[iAm-1] + _b2NT*vetAux[iAm-2];
    vetAux[pred(qtdAm)-iAm]:= _a0NT*vetAux2[iAm]  + _a1NT*vetAux2[iAm-1] + _a2NT*vetAux2[iAm-2] +
                   _b1NT*vetAux[pred(qtdAm)-iAm+1] + _b2NT*vetAux[pred(qtdAm)-iAm+2];
  end;
//ajusta amplitude...
  if _NotchBanda = 1 then  // ? para passa banda
    for iAm:= 0 to pred(qtdAm) do
      vetAux2[iAm]:= vetor[iAm]
  else // ? para Notch
    for iAm:= 0 to pred(qtdAm) do
      vetAux2[iAm]:= 0;

  for iAm:= 2 to pred(qtdAm) do
    vetor[iAm]:= round((vetAux[iAm] / sqr(Mod_Hj[Alto_de_Mod_Hj-2]))-vetAux2[iAm]) // Normaliza ***************
//{$R-}
end;//procedure TFiltros.FiltraNT(var vetor: array of smallint; qtdAm: smallint);

function TFiltros.TemFiltro: boolean;
begin
  result:= (_fr_corte_PA > 0) or (_fr_corte_PB > 0)or (_fr_corte_Nt > 0);// or
           //(_fr_corte_CT > 0) ;

end;
procedure TFiltros.FiltraPA(var vetor: array of double; qtdAm: smallint);
var
  iAm, um4 , tres4: integer;
//vetores auxiliares para calculo
  _vetAux, _vetAux2, vetorD: array of double;
begin   {$R+}
  SetLength(_vetAux, 2*qtdAm);
  SetLength(_vetAux2,2* qtdAm);
  SetLength(vetorD, 2*qtdAm); //dobro do tamanho
  um4 := qtdam div 2; tres4 := 2*qtdam - um4;
  for iAm:=0 to pred(2*qtdAm) do
  begin
    _vetAux[iAm]:= 0;
    _vetAux2[iAm]:= 0;
  end;
  for iAm:=um4 to pred(tres4 - 1) do
    vetorD[iAm] := vetor[iAm - um4];//iAm* Sign((iAm mod 20)-10);//
  for iAm:=0 to pred(um4) do
    vetorD[iAm] := vetor[um4-iAm];//iAm* Sign((iAm mod 20)-10);//
  for iAm:= tres4 to pred(2*qtdam) do
    vetorD[iAm] := vetor[pred(2*qtdam) - iAm + um4];//iAm* Sign((iAm mod 20)-10);//
{
  for iAm:=um4 to pred(tres4) do
    vetorD[iAm] := vetor[iAm - um4];//iAm* Sign((iAm mod 20)-10);//
  for iAm:=0 to pred(um4) do
    vetorD[iAm] := vetor[um4-iAm];//iAm* Sign((iAm mod 20)-10);//
  for iAm:= tres4 to pred(2*qtdam) do
    vetorD[iAm] := vetor[pred(2*qtdam) - iAm + um4];//iAm* Sign((iAm mod 20)-10);//
}
  _vetAux[0]:= 0; _vetAux[1]:= 0;
//calcula invertido
    for iAm:= 2 to pred(2*qtdAm) do
    begin
      _vetAux[iAm]:= (_a0PA*vetorD[iAm] + _a1PA*vetorD[iAm-1] + _a2PA*vetorD[iAm-2] +
                    _b1PA*_vetAux[iAm-1] + _b2PA*_vetAux[iAm-2]);
      _vetAux2[pred(2*qtdAm)-iAm] := _vetAux[iAm];
    end;
  _vetAux[0]:= _vetAux[2]/3; _vetAux[1]:= 2*_vetAux[2]/3;
//calcula desinvertendo
{  for iAm:= 2 to pred(qtdAm) do
  begin
    _vetAux[pred(qtdAm)-iAm]:= _a0PB*_vetAux2[iAm]  + _a1PB*_vetAux2[iAm-1] + _a2PB*_vetAux2[iAm-2] +
                   _b1PB*_vetAux[pred(qtdAm)-iAm+1] + _b2PB*_vetAux[pred(qtdAm)-iAm+2];
  end;
}
    for iAm:= 2 to pred(2*qtdAm) do
    begin
      _vetAux[pred(2*qtdAm)-iAm]:= _a0PA*_vetAux2[iAm] + _a1PA*_vetAux2[iAm-1] + _a2PA*_vetAux2[iAm-2] +
                    _b1PA*_vetAux[pred(2*qtdAm)-iAm+1] + _b2PA*_vetAux[pred(2*qtdAm)-iAm+2];
    end;
{    for iAm:= 2 to pred(2*qtdAm) do
    begin
      _vetAux[iAm]:= _a0PA*_vetAux2[iAm] + _a1PA*_vetAux2[iAm-1] + _a2PA*_vetAux2[iAm-2] +
                    _b1PA*_vetAux[iAm-1] + _b2PA*_vetAux[iAm-2];
    end;
}
//ajusta amplitude...
    for iAm:= 2 to pred(qtdAm) do
      vetor[iAm]:= round(_vetAux[um4+iAm]);  {$R-}
//      vetor[iAm]:= round(_vetAux[pred(qtdAm)+iAm]);  {$R-}
end; // procedure TFiltros.FiltraPA(var vetor: array of ; qtdAm: smallint);

procedure TFiltros.FiltraPB(var vetor: array of double; qtdAm: smallint);
var
  iAm: integer;
//vetores auxiliares para calculo
  _vetAux, _vetAux2: array of double;
begin
//{$R+}
  SetLength(_vetAux, qtdAm);
  SetLength(_vetAux2, qtdAm);
  _vetAux[0]:= 0; _vetAux[1]:= 0;
  vetor[0]:= 0; vetor[1]:= 0;
//calcula invertido
  for iAm:= 2 to pred(qtdAm) do
  begin
    _vetAux[iAm]:= _a0PB*vetor[iAm]     + _a1PB*vetor[iAm-1] + _a2PB*vetor[iAm-2] +
                   _b1PB*_vetAux[iAm-1] + _b2PB*_vetAux[iAm-2];
    _vetAux2[pred(qtdAm)-iAm] := _vetAux[iAm];
  end;
//calcula desinvertendo
  for iAm:= 2 to pred(qtdAm) do
  begin
    _vetAux[pred(qtdAm)-iAm]:= _a0PB*_vetAux2[iAm]  + _a1PB*_vetAux2[iAm-1] + _a2PB*_vetAux2[iAm-2] +
                   _b1PB*_vetAux[pred(qtdAm)-iAm+1] + _b2PB*_vetAux[pred(qtdAm)-iAm+2];
  end;
//ajusta amplitude...
//  if _fr_corte_PA = 0 then
    for iAm:= 2 to pred(qtdAm) do
      vetor[iAm]:= round(1*_vetAux[iAm])
//  else
//    for iAm:= 2 to pred(qtdAm) do
//      vetor[pred(qtdAm)-iAm]:= round(1*_vetAux[iAm]);
//{$R-}

end;//procedure TFiltros.FiltraPB(var vetor: array of ; qtdAm: smallint);

end.
