#include "ReShade.fxh"

// A shader that tries to emulate a sony PVM type aperture grille screen but with full brightness.
//
// The novel thing about this shader is that it relies on the HDR shaders to brighten up the image so that when 
// we apply this shader which emulates the apperture grille the resulting screen isn't left too dark.  
//
// I think you need at least a DisplayHDR 600 monitor but to get close to CRT levels of brightness I think DisplayHDR 1000.
// 
// Please Enable HDR in RetroArch 1.10+
// 
// NOTE: when this shader is envoked the Contrast, Peak Luminance and Paper White Luminance in the HDR menu do nothing instead set those values through the shader parameters 
// 
// For this shader set Paper White Luminance to above 700 and Peak Luminance to the peak luminance of your monitor.  
// 
// Also try to use a integer scaling - its just better - overscaling is fine.
// 
// This shader doesn't do any geometry warping or bouncing of light around inside the screen etc - I think these effects just add unwanted noise, I know people disagree. Please feel free to make you own and add them
// 
// Dont use this shader directly - use the hdr\crt-make-model-hdr.slangp where make and model are the make and model of the CRT you want.

//#pragma format A2B10G10R10_UNORM_PACK32


// #pragma parameter hcrt_title                         "SONY MEGATRON COLOUR VIDEO MONITOR"                           0.0      0.0   0.0001   0.0001
// #pragma parameter hcrt_space0                        " "                                                            0.0      0.0   0.0001   0.0001
// #pragma parameter hcrt_support0                      "SDR mode: Turn up your TV's brightness as high as possible"   0.0      0.0   0.0001   0.0001
// #pragma parameter hcrt_support1                      "HDR mode: Set the peak luminance to that of your TV."         0.0      0.0   0.0001   0.0001
// #pragma parameter hcrt_support2                      "Then adjust paper white luminance until it looks right"       0.0      0.0   0.0001   0.0001
// #pragma parameter hcrt_support3                      " "                                                            0.0      0.0   0.0001   0.0001
// #pragma parameter hcrt_support4                      "Default white points for the different colour systems:"       0.0      0.0   0.0001   0.0001
// #pragma parameter hcrt_support5                      "709: 6500K, PAL: 6500K, NTSC-U: 6500K, NTSC-J: 9300K"         0.0      0.0   0.0001   0.0001
// #pragma parameter hcrt_space1                        " "                                                            0.0      0.0   0.0001   0.0001
// #pragma parameter hcrt_user_settings                 "YOUR DISPLAY'S SETTINGS:"                                     0.0      0.0   0.0001   0.0001
// #pragma parameter hcrt_hdr                           "    SDR | HDR"                                                1.0      0.0   1.0      1.0
// #pragma parameter hcrt_colour_space                  "    SDR: Display's Colour Space: r709 | sRGB | DCI-P3"        1.0      0.0   2.0      1.0
// #pragma parameter hcrt_max_nits                      "    HDR: Display's Peak Luminance"                            700.0    0.0   10000.0  10.0
// #pragma parameter hcrt_paper_white_nits              "    HDR: Display's Paper White Luminance"                     700.0    0.0   10000.0  10.0
// #pragma parameter hcrt_expand_gamut                  "    HDR: Original/Vivid"                                      0.0      0.0   1.0      1.0
// #pragma parameter hcrt_lcd_resolution                "    Display's Resolution: 4K | 8K"                            0.0      0.0   1.0      1.0
// #pragma parameter hcrt_lcd_subpixel                  "    Display's Subpixel Layout: RGB | BGR"                     0.0      0.0   1.0      1.0
// #pragma parameter hcrt_space2                        " "                                                            0.0      0.0   0.0001   0.0001
// #pragma parameter hcrt_developer_settings            "CRT SETTINGS:"                                                0.0      0.0   0.0001   0.0001
// #pragma parameter hcrt_crt_screen_type               "    Screen Type: APERTURE GRILLE | SHADOW MASK | SLOT MASK"   0.0      0.0   3.0      1.0
// #pragma parameter hcrt_crt_resolution                "    Resolution: 300TVL | 600TVL | 800TVL | 1000TVL"           1.0      0.0   3.0      1.0
// #pragma parameter hcrt_colour_system                 "    Colour System: r709 | PAL | NTSC-U | NTSC-J"              2.0      0.0   3.0      1.0
// #pragma parameter hcrt_white_temperature             "    White Temperature Offset (Kelvin)"                        0.0      -5000.0  12000.0      100.0
// #pragma parameter hcrt_brightness                    "    Brightness"                                               0.0      -1.0  1.0      0.01
// #pragma parameter hcrt_contrast                      "    Contrast"                                                 0.0      -1.0  1.0      0.01
// #pragma parameter hcrt_saturation                    "    Saturation"                                               0.0      -1.0   1.0     0.01
// #pragma parameter hcrt_gamma_in                      "    Gamma In"                                                 0.0      -1.0   1.0     0.01
// #pragma parameter hcrt_gamma_out                     "    Gamma Out"                                                0.0      -0.4   0.4     0.005
// #pragma parameter hcrt_pin_phase                     "    Pin Phase"                                                0.00    -0.2   0.2      0.01
// #pragma parameter hcrt_pin_amp                       "    Pin Amp"                                                  0.00    -0.2   0.2      0.01
// #pragma parameter hcrt_space3                        " "                                                            0.0      0.0   0.0001   0.0001
// #pragma parameter hcrt_developer_settings0           "    VERTICAL SETTINGS:"                                       0.0      0.0   0.0001   0.0001
// #pragma parameter hcrt_v_size                        "        Vertical Size"                                        1.00     0.8   1.2      0.01
// #pragma parameter hcrt_v_cent                        "        Vertical Center"                                      0.00  -200.0 200.0      1.0
// #pragma parameter hcrt_red_vertical_convergence      "        Red Vertical Deconvergence"                           0.00     -10.0 10.0     0.01
// #pragma parameter hcrt_green_vertical_convergence    "        Green Vertical Deconvergence"                         0.00     -10.0 10.0     0.01
// #pragma parameter hcrt_blue_vertical_convergence     "        Blue Vertical Deconvergence"                          0.00     -10.0 10.0     0.01
// #pragma parameter hcrt_red_scanline_min              "        Red Scanline Min"                                     0.50     0.0   2.0      0.01 
// #pragma parameter hcrt_red_scanline_max              "        Red Scanline Max"                                     1.00     0.0   2.0      0.01 
// #pragma parameter hcrt_red_scanline_attack           "        Red Scanline Attack"                                  0.20     0.0   1.0      0.01
// #pragma parameter hcrt_green_scanline_min            "        Green Scanline Min"                                   0.50     0.0   2.0      0.01 
// #pragma parameter hcrt_green_scanline_max            "        Green Scanline Max"                                   1.00     0.0   2.0      0.01 
// #pragma parameter hcrt_green_scanline_attack         "        Green Scanline Attack"                                0.20     0.0   1.0      0.01
// #pragma parameter hcrt_blue_scanline_min             "        Blue Scanline Min"                                    0.50     0.0   2.0      0.01 
// #pragma parameter hcrt_blue_scanline_max             "        Blue Scanline Max"                                    1.00     0.0   2.0      0.01 
// #pragma parameter hcrt_blue_scanline_attack          "        Blue Scanline Attack"                                 0.20     0.0   1.0      0.01
// #pragma parameter hcrt_space4                        " "                                                            0.0      0.0   0.0001   0.0001
// #pragma parameter hcrt_developer_settings1           "    HORIZONTAL SETTINGS:"                                     0.0      0.0   0.0001   0.0001
// #pragma parameter hcrt_h_size                        "        Horizontal Size"                                      1.00     0.8   1.2      0.01
// #pragma parameter hcrt_h_cent                        "        Horizontal Center"                                    0.00  -200.0 200.0      1.0
// #pragma parameter hcrt_red_horizontal_convergence    "        Red Horizontal Deconvergence"                         0.00     -10.0 10.0     0.01
// #pragma parameter hcrt_green_horizontal_convergence  "        Green Horizontal Deconvergence"                       0.00     -10.0 10.0     0.01
// #pragma parameter hcrt_blue_horizontal_convergence   "        Blue Horizontal Deconvergence"                        0.00     -10.0 10.0     0.01
// #pragma parameter hcrt_red_beam_sharpness            "        Red Beam Sharpness"                                   1.75     0.0   5.0      0.05
// #pragma parameter hcrt_red_beam_attack               "        Red Beam Attack"                                      0.50     0.0   2.0      0.01
// #pragma parameter hcrt_green_beam_sharpness          "        Green Beam Sharpness"                                 1.75     0.0   5.0      0.05
// #pragma parameter hcrt_green_beam_attack             "        Green Beam Attack"                                    0.50     0.0   2.0      0.01
// #pragma parameter hcrt_blue_beam_sharpness           "        Blue Beam Sharpness"                                  1.75     0.0   5.0      0.05
// #pragma parameter hcrt_blue_beam_attack              "        Blue Beam Attack"                                     0.50     0.0   2.0      0.01



uniform float HCRT_HDR                             <ui_type = "drag"; ui_min = 0.0; ui_max = 1.0;     ui_step = 1.0;  ui_label = "SDR | HDR";> = 1.0;
uniform float HCRT_COLOUR_ACCURATE                 <ui_type = "drag"; ui_min = 0.0; ui_max = 1.0;     ui_step = 1.0;  ui_label = "Mask Accurate/Colour Accurate";> = 1.0;
uniform float HCRT_OUTPUT_COLOUR_SPACE             <ui_type = "drag"; ui_min = 0.0; ui_max = 2.0;     ui_step = 1.0;  ui_label = "SDR: Display's Colour Space: r709 | sRGB | DCI-P3";> = 1.0;
uniform float HCRT_GAMMA_OUT                       <ui_type = "drag"; ui_min = 1.0; ui_max = 5.0;     ui_step = 0.01; ui_label = "SDR: Display's Gamma";> = 2.4;
uniform float HCRT_MAX_NITS                        <ui_type = "drag"; ui_min = 0.0; ui_max = 10000.0; ui_step = 10.0; ui_label = "HDR: Display's Peak Luminance";> = 1000.0;
uniform float HCRT_PAPER_WHITE_NITS                <ui_type = "drag"; ui_min = 0.0; ui_max = 10000.0; ui_step = 10.0; ui_label = "HDR: Display's Paper White Luminance";> = 200.0;
uniform float HCRT_EXPAND_GAMUT                    <ui_type = "drag"; ui_min = 0.0; ui_max = 1.0;     ui_step = 1.0;  ui_label = "HDR: Original/Vivid";> = 1.0;
uniform float HCRT_LCD_RESOLUTION                  <ui_type = "drag"; ui_min = 0.0; ui_max = 2.0;     ui_step = 1.0;  ui_label = "Display's Resolution: 1080p | 4K | 8K";> = 1.0;
uniform float HCRT_LCD_SUBPIXEL                    <ui_type = "drag"; ui_min = 0.0; ui_max = 2.0;     ui_step = 1.0;  ui_label = "Display's Subpixel Layout: RGB | RWBG (OLED) | BGR";> = 0.0;

uniform float HCRT_CRT_SCREEN_TYPE                 <ui_type = "drag"; ui_min = 0.0; ui_max = 2.0;     ui_step = 1.0;  ui_label = "Screen Type: APERTURE GRILLE | SHADOW MASK | SLOT MASK";> = 0.0;
uniform float HCRT_CRT_RESOLUTION                  <ui_type = "drag"; ui_min = 0.0; ui_max = 3.0;     ui_step = 1.0;  ui_label = "Resolution: 300TVL | 600TVL | 800TVL | 1000TVL";> = 1.0;
uniform float HCRT_CRT_COLOUR_SYSTEM               <ui_type = "drag"; ui_min = 0.0; ui_max = 3.0;     ui_step = 1.0;  ui_label = "Colour System: r709 | PAL | NTSC-U | NTSC-J";> = 3.0;
uniform float HCRT_WHITE_TEMPERATURE               <ui_type = "drag"; ui_min = -5000.0; ui_max = 12000.0;     ui_step = 100.0;  ui_label = "White Temperature Offset (Kelvin)";> = 0.0;
uniform float HCRT_BRIGHTNESS                      <ui_type = "drag"; ui_min = -1.0; ui_max = 1.0;    ui_step = 0.01;  ui_label = "Brightness";> = 0.0;
uniform float HCRT_CONTRAST                        <ui_type = "drag"; ui_min = -1.0; ui_max = 1.0;    ui_step = 0.01;  ui_label = "Contrast";> = 0.0;
uniform float HCRT_SATURATION                      <ui_type = "drag"; ui_min = -1.0; ui_max = 1.0;    ui_step = 0.01;  ui_label = "Saturation";> = 0.0;
uniform float HCRT_GAMMA_IN                        <ui_type = "drag"; ui_min = 1.0;  ui_max = 5.0;    ui_step = 0.01;  ui_label = "Gamma";> = 2.22;
uniform float HCRT_PIN_PHASE                       <ui_type = "drag"; ui_min = -0.2; ui_max = 0.2;    ui_step = 0.01;  ui_label = "Pin Phase";> = 0.0;
uniform float HCRT_PIN_AMP                         <ui_type = "drag"; ui_min = -0.2; ui_max = 0.2;    ui_step = 0.01;  ui_label = "Pin Amp";> = 0.0;

uniform float HCRT_V_SIZE                          <ui_type = "drag"; ui_min = 0.0; ui_max = 1.0;     ui_step = 0.01;  ui_label = "Vertical Size";> = 1.0;
uniform float HCRT_V_CENT                          <ui_type = "drag"; ui_min = -200.0; ui_max = 200.0;ui_step = 1.0;   ui_label = "Vertical Center";> = 0.0;
uniform float HCRT_RED_VERTICAL_CONVERGENCE        <ui_type = "drag"; ui_min = -10.0 ; ui_max = 10.0; ui_step = 0.01;  ui_label = "Red Vertical Deconvergence";> = -0.14;
uniform float HCRT_GREEN_VERTICAL_CONVERGENCE      <ui_type = "drag"; ui_min = -10.0 ; ui_max = 10.0; ui_step = 0.01;  ui_label = "Green Vertical Deconvergence";> = 0.0;
uniform float HCRT_BLUE_VERTICAL_CONVERGENCE       <ui_type = "drag"; ui_min = -10.0 ; ui_max = 10.0; ui_step = 0.01;  ui_label = "Blue Vertical Deconvergence";> = 0.0;
uniform float HCRT_RED_SCANLINE_MIN                <ui_type = "drag"; ui_min = 0.0; ui_max = 1.0;     ui_step = 0.01;  ui_label = "Red Scanline Min";> = 0.55;
uniform float HCRT_RED_SCANLINE_MAX                <ui_type = "drag"; ui_min = 0.0; ui_max = 1.0;     ui_step = 0.01;  ui_label = "Red Scanline Max";> = 0.82;
uniform float HCRT_RED_SCANLINE_ATTACK             <ui_type = "drag"; ui_min = 0.0; ui_max = 1.0;     ui_step = 0.01;  ui_label = "Red Scanline Attack";> = 0.65;
uniform float HCRT_GREEN_SCANLINE_MIN              <ui_type = "drag"; ui_min = 0.0; ui_max = 1.0;     ui_step = 0.01;  ui_label = "Green Scanline Min";> = 0.55;
uniform float HCRT_GREEN_SCANLINE_MAX              <ui_type = "drag"; ui_min = 0.0; ui_max = 1.0;     ui_step = 0.01;  ui_label = "Green Scanline Max";> = 0.90;
uniform float HCRT_GREEN_SCANLINE_ATTACK           <ui_type = "drag"; ui_min = 0.0; ui_max = 1.0;     ui_step = 0.01;  ui_label = "Green Scanline Attack";> = 0.13;
uniform float HCRT_BLUE_SCANLINE_MIN               <ui_type = "drag"; ui_min = 0.0; ui_max = 1.0;     ui_step = 0.01;  ui_label = "Blue Scanline Min";> = 0.72;
uniform float HCRT_BLUE_SCANLINE_MAX               <ui_type = "drag"; ui_min = 0.0; ui_max = 1.0;     ui_step = 0.01;  ui_label = "Blue Scanline Max";> = 1.0;
uniform float HCRT_BLUE_SCANLINE_ATTACK            <ui_type = "drag"; ui_min = 0.0; ui_max = 1.0;     ui_step = 0.01;  ui_label = "Blue Scanline Attack";> = 0.65;

uniform float HCRT_H_SIZE                          <ui_type = "drag"; ui_min = 0.0; ui_max = 1.0;     ui_step = 0.01;  ui_label = "Horizontal Size";> = 1.0;
uniform float HCRT_H_CENT                          <ui_type = "drag"; ui_min = -200.0; ui_max = 200.0;ui_step = 1.0;   ui_label = "Horizontal Center";> = 0.0;
uniform float HCRT_RED_HORIZONTAL_CONVERGENCE      <ui_type = "drag"; ui_min = -10.0 ; ui_max = 10.0; ui_step = 0.01;  ui_label = "Red Horizontal Deconvergence";> = 0.0;
uniform float HCRT_GREEN_HORIZONTAL_CONVERGENCE    <ui_type = "drag"; ui_min = -10.0 ; ui_max = 10.0; ui_step = 0.01;  ui_label = "Green Horizontal Deconvergence";> = 0.0;
uniform float HCRT_BLUE_HORIZONTAL_CONVERGENCE     <ui_type = "drag"; ui_min = -10.0 ; ui_max = 10.0; ui_step = 0.01;  ui_label = "Blue Horizontal Deconvergence";> = 0.0;
uniform float HCRT_RED_BEAM_SHARPNESS              <ui_type = "drag"; ui_min = 0.0; ui_max = 5.0;     ui_step = 0.05;  ui_label = "Red Beam Sharpness";> = 1.75;
uniform float HCRT_RED_BEAM_ATTACK                 <ui_type = "drag"; ui_min = 0.0; ui_max = 2.0;     ui_step = 0.01;  ui_label = "Red Beam Attack";> = 0.72;
uniform float HCRT_GREEN_BEAM_SHARPNESS            <ui_type = "drag"; ui_min = 0.0; ui_max = 5.0;     ui_step = 0.05;  ui_label = "Green Beam Sharpness";> = 1.60;
uniform float HCRT_GREEN_BEAM_ATTACK               <ui_type = "drag"; ui_min = 0.0; ui_max = 2.0;     ui_step = 0.01;  ui_label = "Green Beam Attack";> = 0.80;
uniform float HCRT_BLUE_BEAM_SHARPNESS             <ui_type = "drag"; ui_min = 0.0; ui_max = 5.0;     ui_step = 0.05;  ui_label = "Blue Beam Sharpness";> = 1.90;
uniform float HCRT_BLUE_BEAM_ATTACK                <ui_type = "drag"; ui_min = 0.0; ui_max = 2.0;     ui_step = 0.01;  ui_label = "Blue Beam Attack";> = 0.45;


#define COMPAT_TEXTURE(c, d) tex2D(c, d)


#define CRT_WIDTH    3840.0f
#define CRT_HEIGHT   240.0f

texture SourceTexture { Width = CRT_WIDTH; Height = CRT_HEIGHT; Format = RGBA8; };
sampler Source {Texture = SourceTexture; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; };

texture SDRTexture { Width = CRT_WIDTH; Height = CRT_HEIGHT; Format = RGBA16F; };
sampler SourceSDR {Texture = SDRTexture; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; };

texture HDRTexture { Width = CRT_WIDTH; Height = CRT_HEIGHT; Format = RGBA16F; };
sampler SourceHDR {Texture = HDRTexture; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; };


#define kChannelMask          3
#define kFirstChannelShift    2
#define kSecondChannelShift   4
#define kThirdChannelShift    6

#define kRedId   0
#define kGreenId 1
#define kBlueId  2

#define kRed     (1 | (kRedId << kFirstChannelShift))
#define kGreen   (1 | (kGreenId << kFirstChannelShift))
#define kBlue    (1 | (kBlueId << kFirstChannelShift))
#define kMagenta (2 | (kRedId << kFirstChannelShift) | (kBlueId << kSecondChannelShift))
#define kYellow  (2 | (kRedId << kFirstChannelShift) | (kGreenId << kSecondChannelShift))
#define kCyan    (2 | (kGreenId << kFirstChannelShift) | (kBlueId << kSecondChannelShift))
#define kWhite   (3 | (kRedId << kFirstChannelShift) | (kGreenId << kSecondChannelShift) | (kBlueId << kThirdChannelShift))
#define kBlack   0

#define kRedChannel     float3(1.0, 0.0, 0.0)
#define kGreenChannel   float3(0.0, 1.0, 0.0)
#define kBlueChannel    float3(0.0, 0.0, 1.0)

static const float3 kColourMask[3] = { kRedChannel, kGreenChannel, kBlueChannel };

#define kApertureGrille    0
#define kShadowMask        1
#define kSlotMask          2
#define kBlackWhiteMask    3

#define kBGRAxis           3
#define kTVLAxis           4
#define kResolutionAxis    3

// APERTURE GRILLE MASKS

static const float kApertureGrilleMaskSize[kResolutionAxis * kTVLAxis] = { 
     4.0f, 2.0f, 1.0f, 1.0f ,      // 1080p:   300 TVL, 600 TVL, 800 TVL, 1000 TVL 
     7.0f, 4.0f, 3.0f, 2.0f ,      // 4K:      300 TVL, 600 TVL, 800 TVL, 1000 TVL   
    13.0f, 7.0f, 5.0f, 4.0f   };   // 8K:      300 TVL, 600 TVL, 800 TVL, 1000 TVL


// 1080p 

// 300TVL
#define kMaxApertureGrilleSize       4

#define kRGBX             kRed, kGreen, kBlue, kBlack  
#define kRBGX             kRed, kBlue, kGreen, kBlack  
#define kBGRX             kBlue, kGreen, kRed, kBlack  

static const uint kApertureGrilleMasks1080p300TVL[kBGRAxis * kMaxApertureGrilleSize] = 
{
   kRGBX, kRBGX, kBGRX
};

#undef kMaxApertureGrilleSize

#undef kRGBX           
#undef kRBGX           
#undef kBGRX  

// 600TVL
#define kMaxApertureGrilleSize       2

#define kMG               kMagenta, kGreen  
#define kYB               kYellow, kBlue  
#define kGM               kGreen, kMagenta  

static const uint kApertureGrilleMasks1080p600TVL[kBGRAxis * kMaxApertureGrilleSize] = 
{
   kMG, kYB, kGM
};

#undef kMaxApertureGrilleSize

#undef kMG             
#undef kYB             
#undef kGM             

// 800TVL
#define kMaxApertureGrilleSize       1

#define kW                kWhite  

static const uint kApertureGrilleMasks1080p800TVL[kBGRAxis * kMaxApertureGrilleSize] = 
{
   kW, kW, kW
};

// 1000TVL
static const uint kApertureGrilleMasks1080p1000TVL[kBGRAxis * kMaxApertureGrilleSize] = 
{
   kW, kW, kW
};

#undef kMaxApertureGrilleSize   

#undef kW              


// 4K 

// 300TVL
#define kMaxApertureGrilleSize       7

#define kRRGGBBX          kRed, kRed, kGreen, kGreen, kBlue, kBlue, kBlack  
#define kRRBBGGX          kRed, kRed, kBlue, kBlue, kGreen, kGreen, kBlack  
#define kBBGGRRX          kBlue, kBlue, kGreen, kGreen, kRed, kRed, kBlack  

static const uint kApertureGrilleMasks4K300TVL[kBGRAxis * kMaxApertureGrilleSize] = 
{ 
   kRRGGBBX, kRRBBGGX, kBBGGRRX
};

#undef kMaxApertureGrilleSize 

#undef kRRGGBBX        
#undef kRRBBGGX       
#undef kBBGGRRX  

// 600TVL
#define kMaxApertureGrilleSize       4

#define kRGBX             kRed, kGreen, kBlue, kBlack  
#define kRBGX             kRed, kBlue, kGreen, kBlack  
#define kBGRX             kBlue, kGreen, kRed, kBlack  

static const uint kApertureGrilleMasks4K600TVL[kBGRAxis * kMaxApertureGrilleSize] = 
{ 
   kRGBX, kRBGX, kBGRX 
};

#undef kMaxApertureGrilleSize 

#undef kRGBX           
#undef kRBGX           
#undef kBGRX             

// 800TVL
#define kMaxApertureGrilleSize       3

#define kRGB              kRed, kGreen, kBlue  
#define kGBR              kGreen, kBlue, kRed  
#define kBGR              kBlue, kGreen, kRed  

static const uint kApertureGrilleMasks4K800TVL[kBGRAxis * kMaxApertureGrilleSize] = 
{ 
   kBGR, kGBR, kRGB 
};

#undef kMaxApertureGrilleSize 

#undef kRGB            
#undef kGBR            
#undef kBGR            

// 1000TVL
#define kMaxApertureGrilleSize       2

#define kMG               kMagenta, kGreen  
#define kYB               kYellow, kBlue  
#define kGM               kGreen, kMagenta  

static const uint kApertureGrilleMasks4K1000TVL[kBGRAxis * kMaxApertureGrilleSize] = 
{ 
   kMG, kYB, kGM
};

#undef kMaxApertureGrilleSize  

#undef kMG             
#undef kYB             
#undef kGM             


// 8K 

// 300 TVL
#define kMaxApertureGrilleSize       13

#define kRRRRGGGGBBBBX    kRed, kRed, kRed, kRed, kGreen, kGreen, kGreen, kGreen, kBlue, kBlue, kBlue, kBlue, kBlack  
#define kRRRRBBBBGGGGX    kRed, kRed, kRed, kRed, kBlue, kBlue, kBlue, kBlue, kGreen, kGreen, kGreen, kGreen, kBlack  
#define kBBBBGGGGRRRRX    kBlue, kBlue, kBlue, kBlue, kGreen, kGreen, kGreen, kGreen, kRed, kRed, kRed, kRed, kBlack  

static const uint kApertureGrilleMasks8K300TVL[kBGRAxis * kMaxApertureGrilleSize] = 
{ 
   kRRRRGGGGBBBBX, kRRRRBBBBGGGGX, kBBBBGGGGRRRRX
};

#undef kMaxApertureGrilleSize 

#undef kRRRRGGGGBBBBX  
#undef kRRRRBBBBGGGGX  
#undef kBBBBGGGGRRRRX  

// 600 TVL
#define kMaxApertureGrilleSize       7

#define kRRGGBBX          kRed, kRed, kGreen, kGreen, kBlue, kBlue, kBlack  
#define kRRBBGGX          kRed, kRed, kBlue, kBlue, kGreen, kGreen, kBlack  
#define kBBGGRRX          kBlue, kBlue, kGreen, kGreen, kRed, kRed, kBlack  

static const uint kApertureGrilleMasks8K600TVL[kBGRAxis * kMaxApertureGrilleSize] = 
{ 
   kRRGGBBX, kRRBBGGX, kBBGGRRX 
};

#undef kMaxApertureGrilleSize 

#undef kRRGGBBX        
#undef kRRBBGGX       
#undef kBBGGRRX        

// 800 TVL
#define kMaxApertureGrilleSize       5

#define kRYCBX            kRed, kYellow, kCyan, kBlue, kBlack  
#define kRMCGX            kRed, kMagenta, kCyan, kGreen, kBlack  
#define kBCYRX            kBlue, kCyan, kYellow, kRed, kBlack  

static const uint kApertureGrilleMasks8K800TVL[kBGRAxis * kMaxApertureGrilleSize] = 
{ 
   kRYCBX, kRMCGX, kBCYRX
};

#undef kMaxApertureGrilleSize 

#undef kRYCBX          
#undef kRMCGX          
#undef kBCYRX          

// 1000 TVL
#define kMaxApertureGrilleSize       4

#define kRGBX             kRed, kGreen, kBlue, kBlack  
#define kRBGX             kRed, kBlue, kGreen, kBlack  
#define kBGRX             kBlue, kGreen, kRed, kBlack  

static const uint kApertureGrilleMasks8K1000TVL[kBGRAxis * kMaxApertureGrilleSize] = 
{ 
   kRGBX, kRBGX, kBGRX 
};

#undef kMaxApertureGrilleSize  

#undef kRGBX           
#undef kRBGX           
#undef kBGRX            


// SHADOW MASKS

static const float kShadowMaskSizeX[kResolutionAxis * kTVLAxis] = {   6.0f, 2.0f, 1.0f, 1.0f  ,   12.0f, 6.0f, 2.0f, 2.0f  ,   12.0f, 12.0f, 6.0f, 6.0f   }; 
static const float kShadowMaskSizeY[kResolutionAxis * kTVLAxis] = {   4.0f, 2.0f, 1.0f, 1.0f  ,    8.0f, 4.0f, 2.0f, 2.0f  ,    8.0f,  8.0f, 4.0f, 4.0f   }; 


// 1080p 


#define kXXXX                kBlack, kBlack, kBlack, kBlack, kBlack, kBlack  

// 300 TVL
#define kMaxShadowMaskSizeX     6
#define kMaxShadowMaskSizeY     4

#define kGRRBBG              kGreen, kRed, kRed, kBlue, kBlue, kGreen  
#define kBBGGRR              kBlue, kBlue, kGreen, kGreen, kRed, kRed  

#define kBRRGGB              kBlue, kRed, kRed, kGreen, kGreen, kBlue  
#define kGGBBRR              kGreen, kGreen, kBlue, kBlue, kRed, kRed  

#define kGBBRRG              kGreen, kBlue, kBlue, kRed, kRed, kGreen  
#define kRRGGBB              kRed, kRed, kGreen, kGreen, kBlue, kBlue  

#define kGRRBBG_GRRBBG_BBGGRR_BBGGRR    kGRRBBG, kGRRBBG, kBBGGRR, kBBGGRR  
#define kBRRGGB_BRRGGB_GGBBRR_GGBBRR    kBRRGGB, kBRRGGB, kGGBBRR, kGGBBRR  
#define kGBBRRG_GBBRRG_RRGGBB_RRGGBB    kGBBRRG, kGBBRRG, kRRGGBB, kRRGGBB  

static const uint kShadowMasks1080p300TVL[kBGRAxis * kMaxShadowMaskSizeY * kMaxShadowMaskSizeX]  = 
{
   kGRRBBG_GRRBBG_BBGGRR_BBGGRR, kBRRGGB_BRRGGB_GGBBRR_GGBBRR, kGBBRRG_GBBRRG_RRGGBB_RRGGBB        // 300 TVL
};

#undef kMaxShadowMaskSizeX 
#undef kMaxShadowMaskSizeY 

#undef kGRRBBG           
#undef kBBGGRR       
    
#undef kBRRGGB            
#undef kGGBBRR       

#undef kGBBRRG            
#undef kRRGGBB            

#undef kGRRBBG_GRRBBG_BBGGRR_BBGGRR  
#undef kBRRGGB_BRRGGB_GGBBRR_GGBBRR  
#undef kGBBRRG_GBBRRG_RRGGBB_RRGGBB 


// 600 TVL
#define kMaxShadowMaskSizeX     2
#define kMaxShadowMaskSizeY     2

#define kMG                  kMagenta, kGreen  
#define kGM                  kGreen, kMagenta  

#define kYB                  kYellow, kBlue  
#define kBY                  kBlue, kYellow  

#define kMG_GM               kMG, kGM  
#define kYB_BY               kYB, kBY  
#define kGM_MG               kGM, kMG  

static const uint kShadowMasks1080p600TVL[kBGRAxis * kMaxShadowMaskSizeY * kMaxShadowMaskSizeX]  = 
{
   kMG_GM, kYB_BY, kGM_MG                                                                          // 600 TVL
};

#undef kMaxShadowMaskSizeX 
#undef kMaxShadowMaskSizeY 

#undef kMG               
#undef kGM    

#undef kYB                
#undef kBY           

#undef kMG_GM             
#undef kYB_BY             
#undef kGM_MG             

// 800 TVL
#define kMaxShadowMaskSizeX     1
#define kMaxShadowMaskSizeY     1

#define kW                   kWhite  
#define kW_W                 kW  

static const uint kShadowMasks1080p800TVL[kBGRAxis * kMaxShadowMaskSizeY * kMaxShadowMaskSizeX]  = 
{
   kW_W, kW_W, kW_W                                                                                // 800 TVL
};

// 1000 TVL
static const uint kShadowMasks1080p1000TVL[kBGRAxis * kMaxShadowMaskSizeY * kMaxShadowMaskSizeX]  = 
{
   kW_W, kW_W, kW_W                                                                                // 1000 TVL
};

#undef kMaxShadowMaskSizeX 
#undef kMaxShadowMaskSizeY 

#undef kW       
#undef kW_W


// 4K

// 300 TVL

#define kMaxShadowMaskSizeX     12
#define kMaxShadowMaskSizeY     8

#define kGGRRRRBBBBGG        kGreen, kGreen, kRed, kRed, kRed, kRed, kBlue, kBlue, kBlue, kBlue, kGreen, kGreen  
#define kBBBBGGGGRRRR        kBlue, kBlue, kBlue, kBlue, kGreen, kGreen, kGreen, kGreen, kRed, kRed, kRed, kRed  

#define kBBRRRRGGGGBB        kBlue, kBlue, kRed, kRed, kRed, kRed, kGreen, kGreen, kGreen, kGreen, kBlue, kBlue  
#define kGGGGBBBBRRRR        kGreen, kGreen, kGreen, kGreen, kBlue, kBlue, kBlue, kBlue, kRed, kRed, kRed, kRed  

#define kGGBBBBRRRRGG        kGreen, kGreen, kBlue, kBlue, kBlue, kBlue, kRed, kRed, kRed, kRed, kGreen, kGreen  
#define kRRRRGGGGBBBB        kRed, kRed, kRed, kRed, kGreen, kGreen, kGreen, kGreen, kBlue, kBlue, kBlue, kBlue  

#define kGGRRRRBBBBGG_GGRRRRBBBBGG_GGRRRRBBBBGG_GGRRRRBBBBGG_BBBBGGGGRRRR_BBBBGGGGRRRR_BBBBGGGGRRRR_BBBBGGGGRRRR    kGGRRRRBBBBGG, kGGRRRRBBBBGG, kGGRRRRBBBBGG, kGGRRRRBBBBGG, kBBBBGGGGRRRR, kBBBBGGGGRRRR, kBBBBGGGGRRRR, kBBBBGGGGRRRR  
#define kBBRRRRGGGGBB_BBRRRRGGGGBB_BBRRRRGGGGBB_BBRRRRGGGGBB_GGGGBBBBRRRR_GGGGBBBBRRRR_GGGGBBBBRRRR_GGGGBBBBRRRR    kBBRRRRGGGGBB, kBBRRRRGGGGBB, kBBRRRRGGGGBB, kBBRRRRGGGGBB, kGGGGBBBBRRRR, kGGGGBBBBRRRR, kGGGGBBBBRRRR, kGGGGBBBBRRRR  
#define kGGBBBBRRRRGG_GGBBBBRRRRGG_GGBBBBRRRRGG_GGBBBBRRRRGG_RRRRGGGGBBBB_RRRRGGGGBBBB_RRRRGGGGBBBB_RRRRGGGGBBBB    kGGBBBBRRRRGG, kGGBBBBRRRRGG, kGGBBBBRRRRGG, kGGBBBBRRRRGG, kRRRRGGGGBBBB, kRRRRGGGGBBBB, kRRRRGGGGBBBB, kRRRRGGGGBBBB  

static const uint kShadowMasks4K300TVL[kBGRAxis * kMaxShadowMaskSizeY * kMaxShadowMaskSizeX]  = 
{
   kGGRRRRBBBBGG_GGRRRRBBBBGG_GGRRRRBBBBGG_GGRRRRBBBBGG_BBBBGGGGRRRR_BBBBGGGGRRRR_BBBBGGGGRRRR_BBBBGGGGRRRR, 
   kBBRRRRGGGGBB_BBRRRRGGGGBB_BBRRRRGGGGBB_BBRRRRGGGGBB_GGGGBBBBRRRR_GGGGBBBBRRRR_GGGGBBBBRRRR_GGGGBBBBRRRR,
   kGGBBBBRRRRGG_GGBBBBRRRRGG_GGBBBBRRRRGG_GGBBBBRRRRGG_RRRRGGGGBBBB_RRRRGGGGBBBB_RRRRGGGGBBBB_RRRRGGGGBBBB                                                                                         
};

#undef kMaxShadowMaskSizeX 
#undef kMaxShadowMaskSizeY 

#undef kGGRRRRBBBBGG      
#undef kBBBBGGGGRRRR   

#undef kBBRRRRGGGGBB     
#undef kGGGGBBBBRRRR    

#undef kGGBBBBRRRRGG      
#undef kRRRRGGGGBBBB      

#undef kGGRRRRBBBBGG_GGRRRRBBBBGG_GGRRRRBBBBGG_GGRRRRBBBBGG_BBBBGGGGRRRR_BBBBGGGGRRRR_BBBBGGGGRRRR_BBBBGGGGRRRR  
#undef kBBRRRRGGGGBB_BBRRRRGGGGBB_BBRRRRGGGGBB_BBRRRRGGGGBB_GGGGBBBBRRRR_GGGGBBBBRRRR_GGGGBBBBRRRR_GGGGBBBBRRRR  
#undef kGGBBBBRRRRGG_GGBBBBRRRRGG_GGBBBBRRRRGG_GGBBBBRRRRGG_RRRRGGGGBBBB_RRRRGGGGBBBB_RRRRGGGGBBBB_RRRRGGGGBBBB  


// 600 TVL

#define kMaxShadowMaskSizeX     6
#define kMaxShadowMaskSizeY     4

#define kGRRBBG              kGreen, kRed, kRed, kBlue, kBlue, kGreen  
#define kBBGGRR              kBlue, kBlue, kGreen, kGreen, kRed, kRed  

#define kBRRGGB              kBlue, kRed, kRed, kGreen, kGreen, kBlue  
#define kGGBBRR              kGreen, kGreen, kBlue, kBlue, kRed, kRed  

#define kGBBRRG              kGreen, kBlue, kBlue, kRed, kRed, kGreen  
#define kRRGGBB              kRed, kRed, kGreen, kGreen, kBlue, kBlue  

#define kGRRBBG_GRRBBG_BBGGRR_BBGGRR    kGRRBBG, kGRRBBG, kBBGGRR, kBBGGRR  
#define kBRRGGB_BRRGGB_GGBBRR_GGBBRR    kBRRGGB, kBRRGGB, kGGBBRR, kGGBBRR  
#define kGBBRRG_GBBRRG_RRGGBB_RRGGBB    kGBBRRG, kGBBRRG, kRRGGBB, kRRGGBB  

static const uint kShadowMasks4K600TVL[kBGRAxis * kMaxShadowMaskSizeY * kMaxShadowMaskSizeX]  = 
{
   kGRRBBG_GRRBBG_BBGGRR_BBGGRR, kBRRGGB_BRRGGB_GGBBRR_GGBBRR, kGBBRRG_GBBRRG_RRGGBB_RRGGBB
};

#undef kGRRBBG_GRRBBG_BBGGRR_BBGGRR  
#undef kBRRGGB_BRRGGB_GGBBRR_GGBBRR  
#undef kGBBRRG_GBBRRG_RRGGBB_RRGGBB 

#undef kMaxShadowMaskSizeX 
#undef kMaxShadowMaskSizeY 

#undef kGRRBBG           
#undef kBBGGRR    

#undef kBRRGGB            
#undef kGGBBRR      

#undef kGBBRRG            
#undef kRRGGBB         


// 800 TVL

#define kMaxShadowMaskSizeX     2
#define kMaxShadowMaskSizeY     2

#define kMG                  kMagenta, kGreen  
#define kGM                  kGreen, kMagenta  

#define kYB                  kYellow, kBlue  
#define kBY                  kBlue, kYellow  

#define kMG_GM               kMG, kGM  
#define kYB_BY               kYB, kBY  
#define kGM_MG               kGM, kMG  

static const uint kShadowMasks4K800TVL[kBGRAxis * kMaxShadowMaskSizeY * kMaxShadowMaskSizeX]  = 
{
   kMG_GM, kYB_BY, kGM_MG
};

// 1000 TVL
static const uint kShadowMasks4K1000TVL[kBGRAxis * kMaxShadowMaskSizeY * kMaxShadowMaskSizeX]  = 
{
   kMG_GM, kYB_BY, kGM_MG
};

#undef kMaxShadowMaskSizeX 
#undef kMaxShadowMaskSizeY 

#undef kXXXX     

#undef kMG               
#undef kGM    

#undef kYB                
#undef kBY         

#undef kMG_GM             
#undef kYB_BY             
#undef kGM_MG         


// 8K 

// 300 TVL
#define kMaxShadowMaskSizeX     12
#define kMaxShadowMaskSizeY     8

#define kGGRRRRBBBBGG        kGreen, kGreen, kRed, kRed, kRed, kRed, kBlue, kBlue, kBlue, kBlue, kGreen, kGreen  
#define kBBBBGGGGRRRR        kBlue, kBlue, kBlue, kBlue, kGreen, kGreen, kGreen, kGreen, kRed, kRed, kRed, kRed  

#define kBBRRRRGGGGBB        kBlue, kBlue, kRed, kRed, kRed, kRed, kGreen, kGreen, kGreen, kGreen, kBlue, kBlue  
#define kGGGGBBBBRRRR        kGreen, kGreen, kGreen, kGreen, kBlue, kBlue, kBlue, kBlue, kRed, kRed, kRed, kRed  

#define kGGBBBBRRRRGG        kGreen, kGreen, kBlue, kBlue, kBlue, kBlue, kRed, kRed, kRed, kRed, kGreen, kGreen  
#define kRRRRGGGGBBBB        kRed, kRed, kRed, kRed, kGreen, kGreen, kGreen, kGreen, kBlue, kBlue, kBlue, kBlue  

#define kGGRRRRBBBBGG_GGRRRRBBBBGG_GGRRRRBBBBGG_GGRRRRBBBBGG_BBBBGGGGRRRR_BBBBGGGGRRRR_BBBBGGGGRRRR_BBBBGGGGRRRR    kGGRRRRBBBBGG, kGGRRRRBBBBGG, kGGRRRRBBBBGG, kGGRRRRBBBBGG, kBBBBGGGGRRRR, kBBBBGGGGRRRR, kBBBBGGGGRRRR, kBBBBGGGGRRRR  
#define kBBRRRRGGGGBB_BBRRRRGGGGBB_BBRRRRGGGGBB_BBRRRRGGGGBB_GGGGBBBBRRRR_GGGGBBBBRRRR_GGGGBBBBRRRR_GGGGBBBBRRRR    kBBRRRRGGGGBB, kBBRRRRGGGGBB, kBBRRRRGGGGBB, kBBRRRRGGGGBB, kGGGGBBBBRRRR, kGGGGBBBBRRRR, kGGGGBBBBRRRR, kGGGGBBBBRRRR  
#define kGGBBBBRRRRGG_GGBBBBRRRRGG_GGBBBBRRRRGG_GGBBBBRRRRGG_RRRRGGGGBBBB_RRRRGGGGBBBB_RRRRGGGGBBBB_RRRRGGGGBBBB    kGGBBBBRRRRGG, kGGBBBBRRRRGG, kGGBBBBRRRRGG, kGGBBBBRRRRGG, kRRRRGGGGBBBB, kRRRRGGGGBBBB, kRRRRGGGGBBBB, kRRRRGGGGBBBB  

static const uint kShadowMasks8K300TVL[kBGRAxis * kMaxShadowMaskSizeY * kMaxShadowMaskSizeX]  = 
{
   kGGRRRRBBBBGG_GGRRRRBBBBGG_GGRRRRBBBBGG_GGRRRRBBBBGG_BBBBGGGGRRRR_BBBBGGGGRRRR_BBBBGGGGRRRR_BBBBGGGGRRRR,
   kBBRRRRGGGGBB_BBRRRRGGGGBB_BBRRRRGGGGBB_BBRRRRGGGGBB_GGGGBBBBRRRR_GGGGBBBBRRRR_GGGGBBBBRRRR_GGGGBBBBRRRR,
   kGGBBBBRRRRGG_GGBBBBRRRRGG_GGBBBBRRRRGG_GGBBBBRRRRGG_RRRRGGGGBBBB_RRRRGGGGBBBB_RRRRGGGGBBBB_RRRRGGGGBBBB                    
};

// 600 TVL
static const uint kShadowMasks8K600TVL[kBGRAxis * kMaxShadowMaskSizeY * kMaxShadowMaskSizeX]  = 
{
   kGGRRRRBBBBGG_GGRRRRBBBBGG_GGRRRRBBBBGG_GGRRRRBBBBGG_BBBBGGGGRRRR_BBBBGGGGRRRR_BBBBGGGGRRRR_BBBBGGGGRRRR, 
   kBBRRRRGGGGBB_BBRRRRGGGGBB_BBRRRRGGGGBB_BBRRRRGGGGBB_GGGGBBBBRRRR_GGGGBBBBRRRR_GGGGBBBBRRRR_GGGGBBBBRRRR,
   kGGBBBBRRRRGG_GGBBBBRRRRGG_GGBBBBRRRRGG_GGBBBBRRRRGG_RRRRGGGGBBBB_RRRRGGGGBBBB_RRRRGGGGBBBB_RRRRGGGGBBBB
};

#undef kMaxShadowMaskSizeX 
#undef kMaxShadowMaskSizeY 

#undef kGGRRRRBBBBGG      
#undef kBBBBGGGGRRRR      

#undef kBBRRRRGGGGBB     
#undef kGGGGBBBBRRRR      

#undef kGGBBBBRRRRGG      
#undef kRRRRGGGGBBBB      

#undef kGGRRRRBBBBGG_GGRRRRBBBBGG_GGRRRRBBBBGG_GGRRRRBBBBGG_BBBBGGGGRRRR_BBBBGGGGRRRR_BBBBGGGGRRRR_BBBBGGGGRRRR  
#undef kBBRRRRGGGGBB_BBRRRRGGGGBB_BBRRRRGGGGBB_BBRRRRGGGGBB_GGGGBBBBRRRR_GGGGBBBBRRRR_GGGGBBBBRRRR_GGGGBBBBRRRR  
#undef kGGBBBBRRRRGG_GGBBBBRRRRGG_GGBBBBRRRRGG_GGBBBBRRRRGG_RRRRGGGGBBBB_RRRRGGGGBBBB_RRRRGGGGBBBB_RRRRGGGGBBBB  

// 800 TVL
#define kMaxShadowMaskSizeX     6
#define kMaxShadowMaskSizeY     4

#define kGRRBBG              kGreen, kRed, kRed, kBlue, kBlue, kGreen  
#define kBBGGRR              kBlue, kBlue, kGreen, kGreen, kRed, kRed  

#define kBRRGGB              kBlue, kRed, kRed, kGreen, kGreen, kBlue  
#define kGGBBRR              kGreen, kGreen, kBlue, kBlue, kRed, kRed  

#define kGBBRRG              kGreen, kBlue, kBlue, kRed, kRed, kGreen  
#define kRRGGBB              kRed, kRed, kGreen, kGreen, kBlue, kBlue  

#define kGRRBBG_GRRBBG_BBGGRR_BBGGRR    kGRRBBG, kGRRBBG, kBBGGRR, kBBGGRR  
#define kBRRGGB_BRRGGB_GGBBRR_GGBBRR    kBRRGGB, kBRRGGB, kGGBBRR, kGGBBRR  
#define kGBBRRG_GBBRRG_RRGGBB_RRGGBB    kGBBRRG, kGBBRRG, kRRGGBB, kRRGGBB  

static const uint kShadowMasks8K800TVL[kBGRAxis * kMaxShadowMaskSizeY * kMaxShadowMaskSizeX]  = 
{
   kGRRBBG_GRRBBG_BBGGRR_BBGGRR, kBRRGGB_BRRGGB_GGBBRR_GGBBRR, kGBBRRG_GBBRRG_RRGGBB_RRGGBB
};

// 1000 TVL
static const uint kShadowMasks8K1000TVL[kBGRAxis * kMaxShadowMaskSizeY * kMaxShadowMaskSizeX]  = 
{
   kGRRBBG_GRRBBG_BBGGRR_BBGGRR, kBRRGGB_BRRGGB_GGBBRR_GGBBRR, kGBBRRG_GBBRRG_RRGGBB_RRGGBB
};

#undef kMaxShadowMaskSizeX 
#undef kMaxShadowMaskSizeY 

#undef kGRRBBG           
#undef kBBGGRR            

#undef kBRRGGB            
#undef kGGBBRR            

#undef kGBBRRG            
#undef kRRGGBB         

#undef kGRRBBG_GRRBBG_BBGGRR_BBGGRR  
#undef kBRRGGB_BRRGGB_GGBBRR_GGBBRR  
#undef kGBBRRG_GBBRRG_RRGGBB_RRGGBB 

// SLOT MASKS

#define kMaxSlotSizeX      2

static const float kSlotMaskSizeX[kResolutionAxis * kTVLAxis] = {   4.0f, 2.0f, 1.0f, 1.0f  ,   7.0f, 4.0f, 3.0f, 2.0f  ,   7.0f, 7.0f, 5.0f, 4.0f   }; //1080p: 300 TVL, 600 TVL, 800 TVL, 1000 TVL   4K: 300 TVL, 600 TVL, 800 TVL, 1000 TVL   8K: 300 TVL, 600 TVL, 800 TVL, 1000 TVL
static const float kSlotMaskSizeY[kResolutionAxis * kTVLAxis] = {   4.0f, 4.0f, 1.0f, 1.0f  ,   8.0f, 6.0f, 4.0f, 4.0f  ,   6.0f, 6.0f, 4.0f, 4.0f   }; //1080p: 300 TVL, 600 TVL, 800 TVL, 1000 TVL   4K: 300 TVL, 600 TVL, 800 TVL, 1000 TVL   8K: 300 TVL, 600 TVL, 800 TVL, 1000 TVL


// 1080p 


// 300 TVL
#define kMaxSlotMaskSize   4
#define kMaxSlotSizeY      4

#define kXXXX       kBlack, kBlack, kBlack, kBlack  

#define kRGBX       kRed, kGreen, kBlue, kBlack  
#define kRBGX       kRed, kBlue, kGreen, kBlack  
#define kBGRX       kBlue, kGreen, kRed, kBlack  

#define kRGBXRGBX_RGBXXXXX_RGBXRGBX_XXXXRGBX       kRGBX, kRGBX  ,   kRGBX, kXXXX  ,   kRGBX, kRGBX  ,   kXXXX, kRGBX    
#define kRBGXRBGX_RBGXXXXX_RBGXRBGX_XXXXRBGX       kRBGX, kRBGX  ,   kRBGX, kXXXX  ,   kRBGX, kRBGX  ,   kXXXX, kRBGX    
#define kBGRXBGRX_BGRXXXXX_BGRXBGRX_XXXXBGRX       kBGRX, kBGRX  ,   kBGRX, kXXXX  ,   kBGRX, kBGRX  ,   kXXXX, kBGRX    

static const uint kSlotMasks1080p300TVL[kBGRAxis * kMaxSlotSizeY * kMaxSlotSizeX * kMaxSlotMaskSize] = 
{
   kRGBXRGBX_RGBXXXXX_RGBXRGBX_XXXXRGBX, kRBGXRBGX_RBGXXXXX_RBGXRBGX_XXXXRBGX, kBGRXBGRX_BGRXXXXX_BGRXBGRX_XXXXBGRX                                                                                       
};

#undef kMaxSlotMaskSize  
#undef kMaxSlotSizeY     

#undef kXXXX

#undef kRGBX     
#undef kRBGX
#undef kBGRX     

#undef kRGBXRGBX_RGBXXXXX_RGBXRGBX_XXXXRGBX   
#undef kRBGXRBGX_RBGXXXXX_RBGXRBGX_XXXXRBGX   
#undef kBGRXBGRX_BGRXXXXX_BGRXBGRX_XXXXBGRX     


// 600 TVL
#define kMaxSlotMaskSize   2
#define kMaxSlotSizeY      4

#define kXX       kBlack, kBlack  

#define kMG         kMagenta, kGreen  
#define kYB         kYellow, kBlue  
#define kGM         kGreen, kMagenta  

#define kMGMG_MGXX_MGMG_XXMG       kMG, kMG  ,   kMG, kXX  ,   kMG, kMG  ,   kXX, kMG    
#define kYBYB_YBXX_YBYB_XXYB       kYB, kYB  ,   kYB, kXX  ,   kYB, kYB  ,   kXX, kYB    
#define kGMGM_GMXX_GMGM_XXGM       kGM, kGM  ,   kGM, kXX  ,   kGM, kGM  ,   kXX, kGM    

static const uint kSlotMasks1080p600TVL[kBGRAxis * kMaxSlotSizeY * kMaxSlotSizeX * kMaxSlotMaskSize] = 
{
   kMGMG_MGXX_MGMG_XXMG, kYBYB_YBXX_YBYB_XXYB, kGMGM_GMXX_GMGM_XXGM
};

#undef kMaxSlotMaskSize  
#undef kMaxSlotSizeY     

#undef kXX

#undef kMG     
#undef kYB  
#undef kGM        

#undef kMGMG_MGXX_MGMG_XXMG  
#undef kYBYB_YBXX_YBYB_XXYB   
#undef kGMGM_GMXX_GMGM_XXGM  


// 800 TVL
#define kMaxSlotMaskSize   1
#define kMaxSlotSizeY      4

#define kX          kBlack  
#define kW          kWhite  

#define kW_W_W_W       kW, kW  ,   kW, kX  ,   kW, kW  ,   kX, kW    

static const uint kSlotMasks1080p800TVL[kBGRAxis * kMaxSlotSizeY * kMaxSlotSizeX * kMaxSlotMaskSize] = 
{
   kW_W_W_W, kW_W_W_W, kW_W_W_W
};

// 1000 TVL
static const uint kSlotMasks1080p1000TVL[kBGRAxis * kMaxSlotSizeY * kMaxSlotSizeX * kMaxSlotMaskSize] = 
{
   kW_W_W_W, kW_W_W_W, kW_W_W_W 
};

#undef kMaxSlotMaskSize  
#undef kMaxSlotSizeY     

#undef kX  
#undef kW   

#undef kW_W_W_W 


// 4K

// 300 TVL
#define kMaxSlotMaskSize   7
#define kMaxSlotSizeY      8

#define kXXXX       kBlack, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack  

#define kRRGGBBX    kRed, kRed, kGreen, kGreen, kBlue, kBlue, kBlack  
#define kRRBBGGX    kRed, kRed, kBlue, kBlue, kGreen, kGreen, kBlack  
#define kBBGGRRX    kBlue, kBlue, kGreen, kGreen, kRed, kRed, kBlack  

#define kRRGGBBXRRGGBBX_RRGGBBXRRGGBBX_RRGGBBXXXXX_RRGGBBXRRGGBBX_RRGGBBXRRGGBBX_XXXXRRGGBBX       kRRGGBBX, kRRGGBBX  ,   kRRGGBBX, kRRGGBBX  ,   kRRGGBBX, kRRGGBBX  ,   kRRGGBBX, kXXXX  ,   kRRGGBBX, kRRGGBBX  ,   kRRGGBBX, kRRGGBBX  ,   kRRGGBBX, kRRGGBBX  ,   kXXXX, kRRGGBBX    
#define kRRBBGGXRRBBGGX_RRBBGGXRRBBGGX_RRBBGGXXXXX_RRBBGGXRRBBGGX_RRBBGGXRRBBGGX_XXXXRRBBGGX       kRRBBGGX, kRRBBGGX  ,   kRRBBGGX, kRRBBGGX  ,   kRRBBGGX, kRRBBGGX  ,   kRRBBGGX, kXXXX  ,   kRRBBGGX, kRRBBGGX  ,   kRRBBGGX, kRRBBGGX  ,   kRRBBGGX, kRRBBGGX  ,   kXXXX, kRRBBGGX    
#define kBBGGRRXBBGGRRX_BBGGRRXBBGGRRX_BBGGRRXXXXX_BBGGRRXBBGGRRX_BBGGRRXBBGGRRX_XXXXBBGGRRX       kBBGGRRX, kBBGGRRX  ,   kBBGGRRX, kBBGGRRX  ,   kBBGGRRX, kBBGGRRX  ,   kBBGGRRX, kXXXX  ,   kBBGGRRX, kBBGGRRX  ,   kBBGGRRX, kBBGGRRX  ,   kBBGGRRX, kBBGGRRX  ,   kXXXX, kBBGGRRX    

static const uint kSlotMasks4K300TVL[kBGRAxis * kMaxSlotSizeY * kMaxSlotSizeX * kMaxSlotMaskSize] = 
{
   kRRGGBBXRRGGBBX_RRGGBBXRRGGBBX_RRGGBBXXXXX_RRGGBBXRRGGBBX_RRGGBBXRRGGBBX_XXXXRRGGBBX, kRRBBGGXRRBBGGX_RRBBGGXRRBBGGX_RRBBGGXXXXX_RRBBGGXRRBBGGX_RRBBGGXRRBBGGX_XXXXRRBBGGX, kBBGGRRXBBGGRRX_BBGGRRXBBGGRRX_BBGGRRXXXXX_BBGGRRXBBGGRRX_BBGGRRXBBGGRRX_XXXXBBGGRRX
};

#undef kMaxSlotMaskSize   
#undef kMaxSlotSizeY   

#undef kXXXX    
  
#undef kRRGGBBX  
#undef kRRBBGGX  
#undef kBBGGRRX 

#undef kRRGGBBXRRGGBBX_RRGGBBXRRGGBBX_RRGGBBXXXXX_RRGGBBXRRGGBBX_RRGGBBXRRGGBBX_XXXXRRGGBBX   
#undef kRRBBGGXRRBBGGX_RRBBGGXRRBBGGX_RRBBGGXXXXX_RRBBGGXRRBBGGX_RRBBGGXRRBBGGX_XXXXRRBBGGX   
#undef kBBGGRRXBBGGRRX_BBGGRRXBBGGRRX_BBGGRRXXXXX_BBGGRRXBBGGRRX_BBGGRRXBBGGRRX_XXXXBBGGRRX   


// 600 TVL
#define kMaxSlotMaskSize   4
#define kMaxSlotSizeY      6

#define kXXXX       kBlack, kBlack, kBlack, kBlack  

#define kRGBX       kRed, kGreen, kBlue, kBlack  
#define kRBGX       kRed, kBlue, kGreen, kBlack  
#define kBGRX       kBlue, kGreen, kRed, kBlack  

#define kRGBXRGBX_RGBXXXXX_RGBXRGBX_XXXXRGBX       kRGBX, kRGBX  ,   kRGBX, kRGBX  ,   kRGBX, kXXXX  ,   kRGBX, kRGBX  ,   kRGBX, kRGBX  ,   kXXXX, kRGBX   
#define kRBGXRBGX_RBGXXXXX_RBGXRBGX_XXXXRBGX       kRBGX, kRBGX  ,   kRBGX, kRBGX  ,   kRBGX, kXXXX  ,   kRBGX, kRBGX  ,   kRBGX, kRBGX  ,   kXXXX, kRBGX   
#define kBGRXBGRX_BGRXXXXX_BGRXBGRX_XXXXBGRX       kBGRX, kBGRX  ,   kBGRX, kBGRX  ,   kBGRX, kXXXX  ,   kBGRX, kBGRX  ,   kBGRX, kBGRX  ,   kXXXX, kBGRX   

static const uint kSlotMasks4K600TVL[kBGRAxis * kMaxSlotSizeY * kMaxSlotSizeX * kMaxSlotMaskSize] = 
{
   kRGBXRGBX_RGBXXXXX_RGBXRGBX_XXXXRGBX, kRBGXRBGX_RBGXXXXX_RBGXRBGX_XXXXRBGX, kBGRXBGRX_BGRXXXXX_BGRXBGRX_XXXXBGRX
};

#undef kMaxSlotMaskSize   
#undef kMaxSlotSizeY   

#undef kXXXX     

#undef kRGBX     
#undef kRBGX
#undef kBGRX

#undef kRGBXRGBX_RGBXXXXX_RGBXRGBX_XXXXRGBX   
#undef kRBGXRBGX_RBGXXXXX_RBGXRBGX_XXXXRBGX   
#undef kBGRXBGRX_BGRXXXXX_BGRXBGRX_XXXXBGRX   


// 800 TVL
#define kMaxSlotMaskSize   3
#define kMaxSlotSizeY      4

#define kXXXX       kBlack, kBlack, kBlack  

#define kBGR        kBlue, kGreen, kRed  
#define kGBR        kGreen, kBlue, kRed  
#define kRGB        kRed, kGreen, kBlue  

#define kBGRBGR_BGRXXX_BGRBGR_XXXBGR       kBGR, kBGR  ,   kBGR, kXXXX  ,   kBGR, kBGR  ,   kXXXX, kBGR    
#define kGBRGBR_GBRXXX_GBRGBR_XXXGBR       kGBR, kGBR  ,   kGBR, kXXXX  ,   kGBR, kGBR  ,   kXXXX, kGBR    
#define kRGBRGB_RGBXXX_RGBRGB_XXXRGB       kRGB, kRGB  ,   kRGB, kXXXX  ,   kRGB, kRGB  ,   kXXXX, kRGB    

static const uint kSlotMasks4K800TVL[kBGRAxis * kMaxSlotSizeY * kMaxSlotSizeX * kMaxSlotMaskSize] = 
{
   kBGRBGR_BGRXXX_BGRBGR_XXXBGR, kGBRGBR_GBRXXX_GBRGBR_XXXGBR, kRGBRGB_RGBXXX_RGBRGB_XXXRGB
};

#undef kMaxSlotMaskSize   
#undef kMaxSlotSizeY   

#undef kXXXX     

#undef kBGR    
#undef kGBR 
#undef kRGB      

#undef kBGRBGR_BGRXXX_BGRBGR_XXXBGR   
#undef kGBRGBR_GBRXXX_GBRGBR_XXXGBR   
#undef kRGBRGB_RGBXXX_RGBRGB_XXXRGB   


// 1000 TVL
#define kMaxSlotMaskSize   2
#define kMaxSlotSizeY      4

#define kXX       kBlack, kBlack  

#define kMG         kMagenta, kGreen  
#define kYB         kYellow, kBlue  
#define kGM         kGreen, kMagenta  

#define kMGMG_MGXX_MGMG_XXMG       kMG, kMG  ,   kMG, kXX  ,   kMG, kMG  ,   kXX, kMG    
#define kYBYB_YBXX_YBYB_XXYB       kYB, kYB  ,   kYB, kXX  ,   kYB, kYB  ,   kXX, kYB    
#define kGMGM_GMXX_GMGM_XXGM       kGM, kGM  ,   kGM, kXX  ,   kGM, kGM  ,   kXX, kGM    

static const uint kSlotMasks4K1000TVL[kBGRAxis * kMaxSlotSizeY * kMaxSlotSizeX * kMaxSlotMaskSize] = 
{
   kMGMG_MGXX_MGMG_XXMG, kYBYB_YBXX_YBYB_XXYB, kGMGM_GMXX_GMGM_XXGM
};

#undef kMaxSlotMaskSize   
#undef kMaxSlotSizeY   

#undef kXX     

#undef kMG     
#undef kYB  
#undef kGM        

#undef kMGMG_MGXX_MGMG_XXMG  
#undef kYBYB_YBXX_YBYB_XXYB   
#undef kGMGM_GMXX_GMGM_XXGM   
#undef kBBGGRRXBBGGRRX_BBGGRRXBBGGRRX_BBGGRRXXXXX_BBGGRRXBBGGRRX_BBGGRRXBBGGRRX_XXXXBBGGRRX   


// 8K

// 300 TVL
#define kMaxSlotMaskSize   7
#define kMaxSlotSizeY      6

#define kXXXX       kBlack, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack  

#define kRRGGBBX    kRed, kRed, kGreen, kGreen, kBlue, kBlue, kBlack  
#define kRRBBGGX    kRed, kRed, kBlue, kBlue, kGreen, kGreen, kBlack  
#define kBBGGRRX    kBlue, kBlue, kGreen, kGreen, kRed, kRed, kBlack  

#define kRRGGBBXRRGGBBX_RRGGBBXRRGGBBX_RRGGBBXXXXX_RRGGBBXRRGGBBX_RRGGBBXRRGGBBX_XXXXRRGGBBX       kRRGGBBX, kRRGGBBX  ,   kRRGGBBX, kRRGGBBX  ,   kRRGGBBX, kXXXX  ,   kRRGGBBX, kRRGGBBX  ,   kRRGGBBX, kRRGGBBX  ,   kXXXX, kRRGGBBX    
#define kRRBBGGXRRBBGGX_RRBBGGXRRBBGGX_RRBBGGXXXXX_RRBBGGXRRBBGGX_RRBBGGXRRBBGGX_XXXXRRBBGGX       kRRBBGGX, kRRBBGGX  ,   kRRBBGGX, kRRBBGGX  ,   kRRBBGGX, kXXXX  ,   kRRBBGGX, kRRBBGGX  ,   kRRBBGGX, kRRBBGGX  ,   kXXXX, kRRBBGGX    
#define kBBGGRRXBBGGRRX_BBGGRRXBBGGRRX_BBGGRRXXXXX_BBGGRRXBBGGRRX_BBGGRRXBBGGRRX_XXXXBBGGRRX       kBBGGRRX, kBBGGRRX  ,   kBBGGRRX, kBBGGRRX  ,   kBBGGRRX, kXXXX  ,   kBBGGRRX, kBBGGRRX  ,   kBBGGRRX, kBBGGRRX  ,   kXXXX, kBBGGRRX    

static const uint kSlotMasks8K300TVL[kBGRAxis * kMaxSlotSizeY * kMaxSlotSizeX * kMaxSlotMaskSize] = 
{
   kRRGGBBXRRGGBBX_RRGGBBXRRGGBBX_RRGGBBXXXXX_RRGGBBXRRGGBBX_RRGGBBXRRGGBBX_XXXXRRGGBBX, kRRBBGGXRRBBGGX_RRBBGGXRRBBGGX_RRBBGGXXXXX_RRBBGGXRRBBGGX_RRBBGGXRRBBGGX_XXXXRRBBGGX, kBBGGRRXBBGGRRX_BBGGRRXBBGGRRX_BBGGRRXXXXX_BBGGRRXBBGGRRX_BBGGRRXBBGGRRX_XXXXBBGGRRX 
};

// 600 TVL
static const uint kSlotMasks8K600TVL[kBGRAxis * kMaxSlotSizeY * kMaxSlotSizeX * kMaxSlotMaskSize] = 
{
   kRRGGBBXRRGGBBX_RRGGBBXRRGGBBX_RRGGBBXXXXX_RRGGBBXRRGGBBX_RRGGBBXRRGGBBX_XXXXRRGGBBX, kRRBBGGXRRBBGGX_RRBBGGXRRBBGGX_RRBBGGXXXXX_RRBBGGXRRBBGGX_RRBBGGXRRBBGGX_XXXXRRBBGGX, kBBGGRRXBBGGRRX_BBGGRRXBBGGRRX_BBGGRRXXXXX_BBGGRRXBBGGRRX_BBGGRRXBBGGRRX_XXXXBBGGRRX 
};

#undef kMaxSlotMaskSize   
#undef kMaxSlotSizeY   

#undef kXXXX    

#undef kRRGGBBX  
#undef kRRBBGGX  
#undef kBBGGRRX 

#undef kRRGGBBXRRGGBBX_RRGGBBXRRGGBBX_RRGGBBXXXXX_RRGGBBXRRGGBBX_RRGGBBXRRGGBBX_XXXXRRGGBBX   
#undef kRRBBGGXRRBBGGX_RRBBGGXRRBBGGX_RRBBGGXXXXX_RRBBGGXRRBBGGX_RRBBGGXRRBBGGX_XXXXRRBBGGX   
#undef kBBGGRRXBBGGRRX_BBGGRRXBBGGRRX_BBGGRRXXXXX_BBGGRRXBBGGRRX_BBGGRRXBBGGRRX_XXXXBBGGRRX   

// 800 TVL
#define kMaxSlotMaskSize   5
#define kMaxSlotSizeY      4

#define kXXXX       kBlack, kBlack, kBlack, kBlack, kBlack  

#define kRYCBX      kRed, kYellow, kCyan, kBlue, kBlack  
#define kRMCGX      kRed, kMagenta, kCyan, kGreen, kBlack  
#define kBCYRX      kBlue, kCyan, kYellow, kRed, kBlack  

#define kRYCBXRYCBX_RYCBXXXXX_RYCBXRYCBX_XXXXRYCBX       kRYCBX, kRYCBX  ,   kRYCBX, kXXXX  ,   kRYCBX, kRYCBX  ,   kXXXX, kRYCBX    
#define kRMCGXRMCGX_RMCGXXXXX_RMCGXRMCGX_XXXXRMCGX       kRMCGX, kRMCGX  ,   kRMCGX, kXXXX  ,   kRMCGX, kRMCGX  ,   kXXXX, kRMCGX    
#define kBCYRXBCYRX_BCYRXXXXX_BCYRXBCYRX_XXXXBCYRX       kBCYRX, kBCYRX  ,   kBCYRX, kXXXX  ,   kBCYRX, kBCYRX  ,   kXXXX, kBCYRX    

static const uint kSlotMasks8K800TVL[kBGRAxis * kMaxSlotSizeY * kMaxSlotSizeX * kMaxSlotMaskSize] = 
{
   kRYCBXRYCBX_RYCBXXXXX_RYCBXRYCBX_XXXXRYCBX, kRMCGXRMCGX_RMCGXXXXX_RMCGXRMCGX_XXXXRMCGX, kBCYRXBCYRX_BCYRXXXXX_BCYRXBCYRX_XXXXBCYRX
};

#undef kMaxSlotMaskSize   
#undef kMaxSlotSizeY   

#undef kXXXX    

#undef kRYCBX    
#undef kRMCGX
#undef kBCYRX    

#undef kRYCBXRYCBX_RYCBXXXXX_RYCBXRYCBX_XXXXRYCBX   
#undef kRMCGXRMCGX_RMCGXXXXX_RMCGXRMCGX_XXXXRMCGX   
#undef kBCYRXBCYRX_BCYRXXXXX_BCYRXBCYRX_XXXXBCYRX   


// 1000 TVL
#define kMaxSlotMaskSize   4
#define kMaxSlotSizeY      4

#define kXXXX       kBlack, kBlack, kBlack, kBlack  

#define kRGBX       kRed, kGreen, kBlue, kBlack  
#define kRBGX       kRed, kBlue, kGreen, kBlack  
#define kBGRX       kBlue, kGreen, kRed, kBlack  

#define kRGBXRGBX_RGBXXXXX_RGBXRGBX_XXXXRGBX       kRGBX, kRGBX  ,   kRGBX, kXXXX  ,   kRGBX, kRGBX  ,   kXXXX, kRGBX    
#define kRBGXRBGX_RBGXXXXX_RBGXRBGX_XXXXRBGX       kRBGX, kRBGX  ,   kRBGX, kXXXX  ,   kRBGX, kRBGX  ,   kXXXX, kRBGX    
#define kBGRXBGRX_BGRXXXXX_BGRXBGRX_XXXXBGRX       kBGRX, kBGRX  ,   kBGRX, kXXXX  ,   kBGRX, kBGRX  ,   kXXXX, kBGRX    

static const uint kSlotMasks8K1000TVL[kBGRAxis * kMaxSlotSizeY * kMaxSlotSizeX * kMaxSlotMaskSize] = 
{
   kRGBXRGBX_RGBXXXXX_RGBXRGBX_XXXXRGBX, kRBGXRBGX_RBGXXXXX_RBGXRBGX_XXXXRBGX, kBGRXBGRX_BGRXXXXX_BGRXBGRX_XXXXBGRX 
};

#undef kMaxSlotMaskSize   
#undef kMaxSlotSizeY   

#undef kXXXX     

#undef kRGBX    
#undef kRBGX  
#undef kBGRX     
 
#undef kRGBXRGBX_RGBXXXXX_RGBXRGBX_XXXXRGBX   
#undef kRBGXRBGX_RBGXXXXX_RBGXRBGX_XXXXRBGX   
#undef kBGRXBGRX_BGRXXXXX_BGRXBGRX_XXXXBGRX   

// BLACK WHITE MASKS
#if ENABLE_BLACK_WHITE_MASKS

#define kMaxBlackWhiteSize       14

#define kW                   kWhite, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack  

#define kWX                  kWhite, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack  
#define kWWX                 kWhite, kWhite, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack  
#define kWWXX                kWhite, kWhite, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack  
#define kWWWWX               kWhite, kWhite, kWhite, kWhite, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack  
#define kWWWWWXX             kWhite, kWhite, kWhite, kWhite, kWhite, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack, kBlack  
#define kWWWWWWWWWWWXXX      kWhite, kWhite, kWhite, kWhite, kWhite, kWhite, kWhite, kWhite, kWhite, kWhite, kWhite, kWhite, kWhite, kWhite /*kBlack, kBlack, kBlack*/  

static const float kBlackWhiteMaskSize[kResolutionAxis * kTVLAxis] = {   4.0f, 2.0f, 1.0f, 1.0f  ,   7.0f, 4.0f, 3.0f, 2.0f  ,   14.0f, 7.0f, 5.0f, 4.0f   }; //4K: 300 TVL, 600 TVL, 800 TVL, 1000 TVL   8K: 300 TVL, 600 TVL, 800 TVL, 1000 TVL

static const uint kBlackWhiteMasks[kResolutionAxis * kTVLAxis * kBGRAxis * kMaxBlackWhiteSize] = {
   { // 1080p
      { kWWXX, kWWXX, kWWXX },                                 // 300 TVL
      { kWX, kWX, kWX },                                       // 600 TVL
      { kW, kW, kW },                                          // 800 TVL
      { kW, kW, kW }                                           // 1000 TVL
   },
   { // 4K
      { kWWWWWXX, kWWWWWXX, kWWWWWXX },                        // 300 TVL
      { kWWXX, kWWXX, kWWXX },                                 // 600 TVL
      { kWWX, kWWX, kWWX },                                    // 800 TVL
      { kWX, kWX, kWX }                                        // 1000 TVL
   },
   { // 8K
      { kWWWWWWWWWWWXXX, kWWWWWWWWWWWXXX, kWWWWWWWWWWWXXX },   // 300 TVL
      { kWWWWWXX, kWWWWWXX, kWWWWWXX },                        // 600 TVL
      { kWWWWX, kWWWWX, kWWWWX },                              // 800 TVL
      { kWWXX, kWWXX, kWWXX }                                  // 1000 TVL
   }
};

#undef kW                
#undef kWX                
#undef kWWX               
#undef kWWXX              
#undef kWWWWX             
#undef kWWWWWXX           
#undef kWWWWWWWWWWWXXX 

#endif // ENABLE_BLACK_WHITE_MASKS

////////////////////////////////////////
// REPLACE THESE

float mod(float x, float y)
{
    return x - y * floor(x / y);
}

float2 mod(float2 x, float2 y)
{
    return x - y * floor(x / y);
}

float3 mod(float3 x, float3 y)
{
    return x - y * floor(x / y);
}

float4 mod(float4 x, float4 y)
{
    return x - y * floor(x / y);
}

////////////////////////////////////////

#define k1080p     0
#define k4K        1
#define k8K        2

#define k300TVL    0
#define k600TVL    1
#define k800TVL    2
#define k1000TVL   3

#define kColourSystems  4

#define kD50            5003.0f
#define kD55            5503.0f
#define kD65            6504.0f
#define kD75            7504.0f
#define kD93            9305.0f

static const float3x3 k709_to_XYZ = float3x3(
   0.412391f, 0.357584f, 0.180481f,
   0.212639f, 0.715169f, 0.072192f,
   0.019331f, 0.119195f, 0.950532f);

static const float3x3 kPAL_to_XYZ = float3x3(
   0.430554f, 0.341550f, 0.178352f,
   0.222004f, 0.706655f, 0.071341f,
   0.020182f, 0.129553f, 0.939322f);

static const float3x3 kNTSC_to_XYZ = float3x3(
   0.393521f, 0.365258f, 0.191677f,
   0.212376f, 0.701060f, 0.086564f,
   0.018739f, 0.111934f, 0.958385f);

static const float3x3 kXYZ_to_709 = float3x3(
    3.240970f, -1.537383f, -0.498611f,
   -0.969244f,  1.875968f,  0.041555f,
    0.055630f, -0.203977f,  1.056972f);

static const float3x3 kColourGamut[kColourSystems] = { k709_to_XYZ, kPAL_to_XYZ, kNTSC_to_XYZ, kNTSC_to_XYZ };

static const float kTemperatures[kColourSystems] = { kD65, kD65, kD65, kD93 }; 

  // Values from: http://blenderartists.org/forum/showthread.php?270332-OSL-Goodness&p=2268693&viewfull=1#post2268693   
static const float3x3 kWarmTemperature = float3x3(
   float3(0.0, -2902.1955373783176,   -8257.7997278925690),
	float3(0.0,  1669.5803561666639,    2575.2827530017594),
	float3(1.0,     1.3302673723350029,    1.8993753891711275));

static const float3x3 kCoolTemperature = float3x3(
   float3( 1745.0425298314172,      1216.6168361476490,    -8257.7997278925690),
   float3(-2666.3474220535695,     -2173.1012343082230,     2575.2827530017594),
	float3(    0.55995389139931482,     0.70381203140554553,    1.8993753891711275));

static const float4x4 kCubicBezier = float4x4( 1.0f,  0.0f,  0.0f,  0.0f,
                               -3.0f,  3.0f,  0.0f,  0.0f,
                                3.0f, -6.0f,  3.0f,  0.0f,
                               -1.0f,  3.0f, -3.0f,  1.0f );

float Bezier(const float t0, const float4 control_points)
{
   float4 t = float4(1.0, t0, t0*t0, t0*t0*t0);
   return dot(t, mul(kCubicBezier, control_points));
}

float3 WhiteBalance(float temperature, float3 colour)
{
   float3x3 m;
   
   if(temperature < kD65)
   { 
      m = kWarmTemperature;
   } 
   else
   {
      m = kCoolTemperature;
   }

   const float3 rgb_temperature = lerp(clamp(float3(m[0] / (clamp(temperature, 1000.0f, 40000.0f).xxx + m[1]) + m[2]), 0.0f.xxx, 1.0f.xxx), 1.0f.xxx, smoothstep(1000.0f, 0.0f, temperature));

   float3 result = colour * rgb_temperature;

   result *= dot(colour, float3(0.2126, 0.7152, 0.0722)) / max(dot(result, float3(0.2126, 0.7152, 0.0722)), 1e-5); // Preserve luminance

   return result;
}

float r601ToLinear_1(const float channel)
{
	//return (channel >= 0.081f) ? pow((channel + 0.099f) * (1.0f / 1.099f), (1.0f / 0.45f)) : channel * (1.0f / 4.5f);
   //return (channel >= 0.081f) ? pow((channel + 0.099f) * (1.0f / 1.099f), HCRT_GAMMA_IN) : channel * (1.0f / 4.5f);
   return pow((channel + 0.099f) * (1.0f / 1.099f), HCRT_GAMMA_IN);
}

float3 r601ToLinear(const float3 colour)
{
	return float3(r601ToLinear_1(colour.r), r601ToLinear_1(colour.g), r601ToLinear_1(colour.b));
}


float r709ToLinear_1(const float channel)
{
	//return (channel >= 0.081f) ? pow((channel + 0.099f) * (1.0f / 1.099f), (1.0f / 0.45f)) : channel * (1.0f / 4.5f);
   //return (channel >= 0.081f) ? pow((channel + 0.099f) * (1.0f / 1.099f), HCRT_GAMMA_IN) : channel * (1.0f / 4.5f);
   return pow((channel + 0.099f) * (1.0f / 1.099f), HCRT_GAMMA_IN);
}

float3 r709ToLinear(const float3 colour)
{
	return float3(r709ToLinear_1(colour.r), r709ToLinear_1(colour.g), r709ToLinear_1(colour.b));
}

// XYZ Yxy transforms found in Dogway's Grade.slang shader

float3 XYZtoYxy(const float3 XYZ)
{
   const float XYZrgb   = XYZ.r + XYZ.g + XYZ.b;
   const float Yxyg     = (XYZrgb <= 0.0f) ? 0.3805f : XYZ.r / XYZrgb;
   const float Yxyb     = (XYZrgb <= 0.0f) ? 0.3769f : XYZ.g / XYZrgb;
   return float3(XYZ.g, Yxyg, Yxyb);
}

float3 YxytoXYZ(const float3 Yxy)
{
   const float Xs    = Yxy.r * (Yxy.g / Yxy.b);
   const float Xsz   = (Yxy.r <= 0.0f) ? 0.0f : 1.0f;
   const float3 XYZ    = float3(Xsz, Xsz, Xsz) * float3(Xs, Yxy.r, (Xs / Yxy.g) - Xs - Yxy.r);
   return XYZ;
}

static const float4 kTopBrightnessControlPoints    = float4(0.0f, 1.0f, 1.0f, 1.0f);
static const float4 kMidBrightnessControlPoints    = float4(0.0f, 1.0f / 3.0f, (1.0f / 3.0f) * 2.0f, 1.0f);
static const float4 kBottomBrightnessControlPoints = float4(0.0f, 0.0f, 0.0f, 1.0f);

float Brightness(const float luminance)
{
   if(HCRT_BRIGHTNESS >= 0.0f)
   {
      return Bezier(luminance, lerp(kMidBrightnessControlPoints, kTopBrightnessControlPoints, HCRT_BRIGHTNESS));
   }
   else
   {
      return Bezier(luminance, lerp(kMidBrightnessControlPoints, kBottomBrightnessControlPoints, abs(HCRT_BRIGHTNESS)));
   }
}

static const float4 kTopContrastControlPoints    = float4(0.0f, 0.0f, 1.0f, 1.0f);
static const float4 kMidContrastControlPoints    = float4(0.0f, 1.0f / 3.0f, (1.0f / 3.0f) * 2.0f, 1.0f);
static const float4 kBottomContrastControlPoints = float4(0.0f, 1.0f, 0.0f, 1.0f);

float Contrast(const float luminance)
{
   if(HCRT_CONTRAST >= 0.0f)
   {
      return Bezier(luminance, lerp(kMidContrastControlPoints, kTopContrastControlPoints, HCRT_CONTRAST));
   }
   else
   {
      return Bezier(luminance, lerp(kMidContrastControlPoints, kBottomContrastControlPoints, abs(HCRT_CONTRAST)));
   }
}

float3 Saturation(const float3 colour)
{
   const float luma           = dot(colour, float3(0.2125, 0.7154, 0.0721));
   const float saturation     = 0.5f + HCRT_SATURATION * 0.5f;

   return clamp(lerp(luma.xxx, colour, saturation.xxx * 2.0f), 0.0f.xxx, 1.0f.xxx);
}

float3 BrightnessContrastSaturation(const float3 xyz)
{
   const float3 Yxy              = XYZtoYxy(xyz);
   const float Y_gamma           = clamp(pow(Yxy.x, 1.0f / 2.4f), 0.0f, 1.0f);
   
   const float Y_brightness      = Brightness(Y_gamma);

   const float Y_contrast        = Contrast(Y_brightness);

   const float3 contrast_linear  = float3(pow(Y_contrast, 2.4f), Yxy.y, Yxy.z);
   const float3 contrast         = clamp(mul(kXYZ_to_709, YxytoXYZ(contrast_linear)), 0.0f, 1.0f);

   const float3 saturation       = Saturation(contrast);

   return saturation;
}

float3 ColourGrade(const float3 colour)
{
   const uint colour_system      = uint(HCRT_CRT_COLOUR_SYSTEM);

   const float3 white_point      = WhiteBalance(kTemperatures[colour_system] + HCRT_WHITE_TEMPERATURE, colour);

   const float3 _linear          = r601ToLinear(white_point); //pow(white_point, ((1.0f / 0.45f) + HCRT_GAMMA_IN).xxx);

   const float3 xyz              = mul(kColourGamut[colour_system], _linear);

   const float3 graded           = BrightnessContrastSaturation(xyz); 

   return graded;
}

////////////////////////////////////////

#define kMaxNitsFor2084     10000.0f
#define kEpsilon            0.0001f

float3 InverseTonemap(const float3 sdr_linear, const float max_nits, const float paper_white_nits)
{
   const float luma                 = dot(sdr_linear, float3(0.2126, 0.7152, 0.0722));  // Rec BT.709 luma coefficients - https://en.wikipedia.org/wiki/Luma_(video) 

   // Inverse reinhard tonemap 
   const float max_value            = (max_nits / paper_white_nits) + kEpsilon;
   const float elbow                = max_value / (max_value - 1.0f);                          
   const float offset               = 1.0f - ((0.5f * elbow) / (elbow - 0.5f));              
   
   const float hdr_luma_inv_tonemap = offset + ((luma * elbow) / (elbow - luma));
   const float sdr_luma_inv_tonemap = luma / ((1.0f + kEpsilon) - luma);                     // Convert the srd < 0.5 to 0.0 -> 1.0 range 

   const float luma_inv_tonemap     = (luma > 0.5f) ? hdr_luma_inv_tonemap : sdr_luma_inv_tonemap;
   const float3 hdr                   = sdr_linear / (luma + kEpsilon) * luma_inv_tonemap;

   return hdr;
}

float3 InverseTonemapConditional(const float3 _linear)
{
   if(HCRT_HDR < 1.0f)
   {
      return _linear;
   }
   else
   {
      return InverseTonemap(_linear, HCRT_MAX_NITS, HCRT_PAPER_WHITE_NITS);
   }
}

////////////////////////////////////////

//#define kMaxNitsFor2084     10000.0f

static const float3x3 k709_to_2020 = float3x3 (
   0.6274040f, 0.3292820f, 0.0433136f,
   0.0690970f, 0.9195400f, 0.0113612f,
   0.0163916f, 0.0880132f, 0.8955950f);

// START Converted from (Copyright (c) Microsoft Corporation - Licensed under the MIT License.)  https://github.com/microsoft/Xbox-ATG-Samples/tree/master/Kits/ATGTK/HDR 
static const float3x3 kExpanded709_to_2020 = float3x3 (
    0.6274040f,  0.3292820f, 0.0433136f,
    0.0457456f,  0.941777f,  0.0124772f,
   -0.00121055f, 0.0176041f, 0.983607f);

static const float3x3 k2020Gamuts[2] = { k709_to_2020, kExpanded709_to_2020 };

float3 LinearToST2084(float3 normalizedLinearValue)
{
   //float3 ST2084 = pow((0.8359375f + 18.8515625f * pow(abs(normalizedLinearValue), float3(0.1593017578f))) / (1.0f + 18.6875f * pow(abs(normalizedLinearValue), float3(0.1593017578f))), float3(78.84375f));
   float3 ST2084 = pow((0.8359375f.xxx + (pow(abs(normalizedLinearValue), 0.1593017578125f.xxx) * 18.8515625f)) / (1.0f.xxx + (pow(abs(normalizedLinearValue), 0.1593017578125f.xxx) * 18.6875f)), 78.84375f.xxx);
   return ST2084;  // Don't clamp between [0..1], so we can still perform operations on scene values higher than 10,000 nits
}
// END Converted from (Copyright (c) Microsoft Corporation - Licensed under the MIT License.)  https://github.com/microsoft/Xbox-ATG-Samples/tree/master/Kits/ATGTK/HDR 

//Convert into HDR10
float3 Hdr10(float3 hdr_linear, float paper_white_nits, float expand_gamut)
{
   float3 rec2020       = mul(k2020Gamuts[uint(expand_gamut)], hdr_linear);
   float3 linearColour  = rec2020 * (paper_white_nits / kMaxNitsFor2084);
   float3 hdr10         = LinearToST2084(linearColour);

   return hdr10;
}

////////////////////////////////////////

static const float3x3 k709_to_XYZ = float3x3(
   0.412391f, 0.357584f, 0.180481f,
   0.212639f, 0.715169f, 0.072192f,
   0.019331f, 0.119195f, 0.950532f);

static const float3x3 kXYZ_to_DCIP3 = float3x3 (
    2.4934969119f, -0.9313836179f, -0.4027107845f,
   -0.8294889696f,  1.7626640603f,  0.0236246858f,
    0.0358458302f, -0.0761723893f,  0.9568845240f);

float LinearTosRGB_1(const float channel)
{
	//return (channel > 0.0031308f) ? (1.055f * pow(channel, 1.0f / HCRT_GAMMA_OUT)) - 0.055f : channel * 12.92f;
   return (1.055f * pow(channel, 1.0f / HCRT_GAMMA_OUT)) - 0.055f;
}

float3 LinearTosRGB(const float3 colour)
{
	return float3(LinearTosRGB_1(colour.r), LinearTosRGB_1(colour.g), LinearTosRGB_1(colour.b));
}

float LinearTo709_1(const float channel)
{
	//return (channel >= 0.018f) ? pow(channel * 1.099f, 0.45f + HCRT_GAMMA_OUT) - 0.099f : channel * 4.5f;
   return pow(channel * 1.099f, 0.45f + HCRT_GAMMA_OUT) - 0.099f;
}

float3 LinearTo709(const float3 colour)
{
	return float3(LinearTo709_1(colour.r), LinearTo709_1(colour.g), LinearTo709_1(colour.b));
}

float3 LinearToDCIP3(const float3 colour)
{
	return clamp(pow(colour, (HCRT_GAMMA_OUT.xxx + 0.2f.xxx)), 0.0f.xxx, 1.0f.xxx);
}

void GammaCorrect(const float3 scanline_colour, inout float3 gamma_corrected)
{
   if(HCRT_HDR < 1.0f)
   {
      if(HCRT_OUTPUT_COLOUR_SPACE == 0.0f)
      {
         gamma_corrected = LinearTo709(scanline_colour);
      }
      else if(HCRT_OUTPUT_COLOUR_SPACE == 1.0f)
      {
         gamma_corrected = LinearTosRGB(scanline_colour);
      }
      else
      {
         gamma_corrected = LinearToDCIP3(scanline_colour);
      }
   }
   else
   {
      gamma_corrected = LinearToST2084(scanline_colour);
   }
}

////////////////////////////////////////

#define kPi    3.1415926536f
#define kEuler 2.718281828459f
#define kMax   1.0f

#define kBeamWidth 0.5f

static const float4 kFallOffControlPoints    = float4(0.0f, 0.0f, 0.0f, 1.0f);
static const float4 kAttackControlPoints     = float4(0.0f, 1.0f, 1.0f, 1.0f);
//static const float4 kScanlineControlPoints = float4(1.0f, 1.0f, 0.0f, 0.0f);

//static const float4x4 kCubicBezier = float4x4( 1.0f,  0.0f,  0.0f,  0.0f,
//                               -3.0f,  3.0f,  0.0f,  0.0f,
//                                3.0f, -6.0f,  3.0f,  0.0f,
//                               -1.0f,  3.0f, -3.0f,  1.0f );

//float Bezier(const float t0, const float4 control_points)
//{
//   float4 t = float4(1.0, t0, t0*t0, t0*t0*t0);
//   return dot(t, control_points * kCubicBezier);
//}

float4 BeamControlPoints(const float beam_attack, const bool falloff)
{
   const float inner_attack = clamp(beam_attack, 0.0f, 1.0);
   const float outer_attack = clamp(beam_attack - 1.0f, 0.0f, 1.0);

   return falloff ? kFallOffControlPoints + float4(0.0f, outer_attack, inner_attack, 0.0f) : kAttackControlPoints - float4(0.0f, inner_attack, outer_attack, 0.0f);
}

float ScanlineColour(const uint channel, 
                     const float2 tex_coord,
                     const float2 source_size, 
                     const float scanline_size, 
                     const float source_tex_coord_x, 
                     const float narrowed_source_pixel_offset, 
                     const float vertical_convergence, 
                     const float beam_attack, 
                     const float scanline_min, 
                     const float scanline_max, 
                     const float scanline_attack, 
                     inout float next_prev)
{
   const float current_source_position_y  = ((tex_coord.y * source_size.y) - vertical_convergence) + next_prev;
   const float current_source_center_y    = floor(current_source_position_y) + 0.5f; 
   
   const float source_tex_coord_y         = current_source_center_y / source_size.y; 

   const float scanline_delta             = frac(current_source_position_y) - 0.5f;

   // Slightly increase the beam width to get maximum brightness
   float beam_distance                    = abs(scanline_delta - next_prev) - (kBeamWidth / scanline_size);
   beam_distance                          = beam_distance < 0.0f ? 0.0f : beam_distance;
   const float scanline_distance          = beam_distance * 2.0f;

   next_prev = scanline_delta > 0.0f ? 1.0f : -1.0f;

   const float2 tex_coord_0                 = float2(source_tex_coord_x, source_tex_coord_y);
   const float2 tex_coord_1                 = float2(source_tex_coord_x + (1.0f / source_size.x), source_tex_coord_y);

   const float sdr_channel_0              = COMPAT_TEXTURE(SourceSDR, tex_coord_0)[channel];
   const float sdr_channel_1              = COMPAT_TEXTURE(SourceSDR, tex_coord_1)[channel];

   const float hdr_channel_0              = COMPAT_TEXTURE(SourceHDR, tex_coord_0)[channel];
   const float hdr_channel_1              = COMPAT_TEXTURE(SourceHDR, tex_coord_1)[channel];

   // Horizontal interpolation between pixels 
   const float horiz_interp               = Bezier(narrowed_source_pixel_offset, BeamControlPoints(beam_attack, sdr_channel_0 > sdr_channel_1));  

   const float hdr_channel                = lerp(hdr_channel_0, hdr_channel_1, horiz_interp);
   const float sdr_channel                = lerp(sdr_channel_0, sdr_channel_1, horiz_interp);

   const float channel_scanline_distance  = clamp(scanline_distance / ((sdr_channel * (scanline_max - scanline_min)) + scanline_min), 0.0f, 1.0f);

   const float4 channel_control_points      = float4(1.0f, 1.0f, sdr_channel * scanline_attack,    0.0f);

   const float luminance                  = Bezier(channel_scanline_distance, channel_control_points);

   return luminance * hdr_channel;
}

float GenerateScanline( const uint channel, 
                        const float2 tex_coord,
                        const float2 source_size, 
                        const float scanline_size, 
                        const float horizontal_convergence, 
                        const float vertical_convergence, 
                        const float beam_sharpness, 
                        const float beam_attack, 
                        const float scanline_min, 
                        const float scanline_max, 
                        const float scanline_attack)
{
   const float current_source_position_x      = (tex_coord.x * source_size.x) - horizontal_convergence;
   const float current_source_center_x        = floor(current_source_position_x) + 0.5f; 
   
   const float source_tex_coord_x             = current_source_center_x / source_size.x; 

   const float source_pixel_offset            = frac(current_source_position_x);

   const float narrowed_source_pixel_offset   = clamp(((source_pixel_offset - 0.5f) * beam_sharpness) + 0.5f, 0.0f, 1.0f);

   float next_prev = 0.0f;

   const float scanline_colour0  = ScanlineColour( channel, 
                                                   tex_coord,
                                                   source_size, 
                                                   scanline_size, 
                                                   source_tex_coord_x, 
                                                   narrowed_source_pixel_offset, 
                                                   vertical_convergence,  
                                                   beam_attack, 
                                                   scanline_min, 
                                                   scanline_max, 
                                                   scanline_attack, 
                                                   next_prev);

   // Optionally sample the neighbouring scanline
   float scanline_colour1 = 0.0f;
   if(scanline_max > 1.0f)
   {
      scanline_colour1           = ScanlineColour( channel, 
                                                   tex_coord,
                                                   source_size, 
                                                   scanline_size, 
                                                   source_tex_coord_x, 
                                                   narrowed_source_pixel_offset,
                                                   vertical_convergence,  
                                                   beam_attack, 
                                                   scanline_min, 
                                                   scanline_max, 
                                                   scanline_attack,  
                                                   next_prev);
   }

   return scanline_colour0 + scanline_colour1;
}

////////////////////////////////////////

void Downsample(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 fragment : SV_Target0)
{
   const float2 source_size = float2(BUFFER_WIDTH, BUFFER_HEIGHT);
   const float2 output_size = float2(CRT_WIDTH, CRT_HEIGHT);

   const float2 tile_size   = source_size / output_size;  

   float3 source = 0.0f.xxx;

   for(float x = -(tile_size.x / 2.0f); x < tile_size.x / 2.0f; x += 1.0f)
   {
      for(float y = -(tile_size.y / 2.0f); y < tile_size.y / 2.0f; y += 1.0f)
      {
         float2 uv = float2(x, y) / source_size;
         source += COMPAT_TEXTURE(ReShade::BackBuffer, texcoord + uv).rgb;
      }
   }

   source = source / (tile_size.x * tile_size.y);

   fragment = float4(source, 1.0);
}

void ColourPass(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 fragment : SV_Target0)
{
   float3 source = COMPAT_TEXTURE(Source, texcoord).rgb;

   const float3 colour   = ColourGrade(source);

   float3 transformed_colour;

   if((HCRT_HDR < 1.0f) && (HCRT_COLOUR_ACCURATE < 1.0f))
   {
      if(HCRT_OUTPUT_COLOUR_SPACE == 2.0f)
      {
         transformed_colour = mul(kXYZ_to_DCIP3, mul(k709_to_XYZ, colour)); 
      }
      else
      {
         transformed_colour = colour;
      }
   }
   else
   {
      transformed_colour = colour;
   }

   fragment = float4(transformed_colour, 1.0);
}
 
void HDRPass(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 fragment : SV_Target0)
{
   float3 source = COMPAT_TEXTURE(SourceSDR, texcoord).rgb;

   const float3 hdr_colour   = InverseTonemapConditional(source);

   float3 transformed_colour;

   if((HCRT_HDR >= 1.0f) && (HCRT_COLOUR_ACCURATE < 1.0f))
   {
      const float3 rec2020  = mul(k2020Gamuts[uint(HCRT_EXPAND_GAMUT)], hdr_colour);
      transformed_colour  = rec2020 * (HCRT_PAPER_WHITE_NITS / kMaxNitsFor2084);
   }
   else
   {      
      transformed_colour = hdr_colour;
   }

   fragment = float4(transformed_colour, 1.0);
}

void SonyMegatronPass(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 fragment : SV_Target0)
{
   const float2 output_size = float2(BUFFER_WIDTH, BUFFER_HEIGHT);
   const float2 source_size = float2(CRT_WIDTH, CRT_HEIGHT);

   const uint screen_type           = uint(HCRT_CRT_SCREEN_TYPE);
   const uint crt_resolution        = uint(HCRT_CRT_RESOLUTION);
   const uint lcd_resolution        = uint(HCRT_LCD_RESOLUTION);
   const uint lcd_subpixel_layout   = uint(HCRT_LCD_SUBPIXEL);

   float2 tex_coord                 = texcoord - 0.5f.xx;
   tex_coord                        = tex_coord * float2(1.0f + (HCRT_PIN_PHASE * tex_coord.y), 1.0f);
   tex_coord                        = tex_coord * float2(HCRT_H_SIZE, HCRT_V_SIZE);
   tex_coord                        = tex_coord + 0.5f.xx;
   tex_coord                        = tex_coord + (float2(HCRT_H_CENT, HCRT_V_CENT) / output_size); 

   const float2 current_position      = texcoord * output_size;

   uint colour_mask = 0;

   switch(screen_type)
   {
      case kApertureGrille:
      {
         uint mask = uint(floor(mod(current_position.x, kApertureGrilleMaskSize[(lcd_resolution * kTVLAxis) + crt_resolution])));

         mask = mask;

         switch(lcd_resolution)
         {
            case k1080p:
            { 
               switch(crt_resolution)
               {
                  case k300TVL:
                  { 
                     colour_mask = kApertureGrilleMasks1080p300TVL[(lcd_subpixel_layout * 4) + mask];      
                     
                     break;
                  }
                  case k600TVL:
                  {
                     colour_mask = kApertureGrilleMasks1080p600TVL[(lcd_subpixel_layout * 2) + mask]; 

                     break;
                  }
                  case k800TVL:
                  {
                     colour_mask = kApertureGrilleMasks1080p800TVL[(lcd_subpixel_layout * 1) + mask]; 

                     break;
                  }
                  case k1000TVL:
                  {
                     colour_mask = kApertureGrilleMasks1080p1000TVL[(lcd_subpixel_layout * 1) + mask]; 

                     break;
                  }
                  default:
                  {
                     break;
                  }                 
               }

               break;
            }
            case k4K:
            {
               switch(crt_resolution)
               {
                  case k300TVL:
                  { 
                     colour_mask = kApertureGrilleMasks4K300TVL[(lcd_subpixel_layout * 7) + mask];      
                     
                     break;
                  }
                  case k600TVL:
                  {
                     colour_mask = kApertureGrilleMasks4K600TVL[(lcd_subpixel_layout * 4) + mask]; 

                     break;
                  }
                  case k800TVL:
                  {
                     colour_mask = kApertureGrilleMasks4K800TVL[(lcd_subpixel_layout * 3) + mask]; 

                     break;
                  }
                  case k1000TVL:
                  {
                     colour_mask = kApertureGrilleMasks4K1000TVL[(lcd_subpixel_layout * 2) + mask]; 

                     break;
                  }
                  default:
                  {
                     break;
                  }                 
               }

               break;
            }
            case k8K:
            {
               switch(crt_resolution)
               {
                  case k300TVL:
                  { 
                     colour_mask = kApertureGrilleMasks8K300TVL[(lcd_subpixel_layout * 13) + mask];      
                     
                     break;
                  }
                  case k600TVL:
                  {
                     colour_mask = kApertureGrilleMasks8K600TVL[(lcd_subpixel_layout * 7) + mask]; 

                     break;
                  }
                  case k800TVL:
                  {
                     colour_mask = kApertureGrilleMasks8K800TVL[(lcd_subpixel_layout * 5) + mask]; 

                     break;
                  }
                  case k1000TVL:
                  {
                     colour_mask = kApertureGrilleMasks8K1000TVL[(lcd_subpixel_layout * 4) + mask]; 

                     break;
                  }
                  default:
                  {
                     break;
                  }                 
               }

               break;
            }
            default:
            {
               break;
            }                 
         }

         break;
      }
      case kShadowMask:
      {
         uint shadow_y = uint(floor(mod(current_position.y, kShadowMaskSizeY[(lcd_resolution * kTVLAxis) + crt_resolution])));

         uint mask = uint(floor(mod(current_position.x, kShadowMaskSizeX[(lcd_resolution * kTVLAxis) + crt_resolution])));

         switch(lcd_resolution)
         {
            case k1080p:
            { 
               switch(crt_resolution)
               {
                  case k300TVL:
                  { 
                     colour_mask = kShadowMasks1080p300TVL[(lcd_subpixel_layout * 4 * 6) + (shadow_y * 6) + mask];      
                     
                     break;
                  }
                  case k600TVL:
                  {
                     colour_mask = kShadowMasks1080p600TVL[(lcd_subpixel_layout * 2 * 2) + (shadow_y * 2) + mask]; 

                     break;
                  }
                  case k800TVL:
                  {
                     colour_mask = kShadowMasks1080p800TVL[(lcd_subpixel_layout * 1 * 1) + (shadow_y * 1) + mask]; 

                     break;
                  }
                  case k1000TVL:
                  {
                     colour_mask = kShadowMasks1080p1000TVL[(lcd_subpixel_layout * 1 * 1) + (shadow_y * 1) + mask]; 

                     break;
                  }
                  default:
                  {
                     break;
                  }                 
               }

               break;
            }
            case k4K:
            {
               switch(crt_resolution)
               {
                  case k300TVL:
                  { 
                     colour_mask = kShadowMasks4K300TVL[(lcd_subpixel_layout * 8 * 12) + (shadow_y * 12) + mask];      
                     
                     break;
                  }
                  case k600TVL:
                  {
                     colour_mask = kShadowMasks4K600TVL[(lcd_subpixel_layout * 4 * 6) + (shadow_y * 6) + mask]; 

                     break;
                  }
                  case k800TVL:
                  {
                     colour_mask = kShadowMasks4K800TVL[(lcd_subpixel_layout * 2 * 2) + (shadow_y * 2) + mask]; 

                     break;
                  }
                  case k1000TVL:
                  {
                     colour_mask = kShadowMasks4K1000TVL[(lcd_subpixel_layout * 2 * 2) + (shadow_y * 2) + mask]; 

                     break;
                  }
                  default:
                  {
                     break;
                  }                 
               }

               break;
            }
            case k8K:
            {
               switch(crt_resolution)
               {
                  case k300TVL:
                  { 
                     colour_mask = kShadowMasks8K300TVL[(lcd_subpixel_layout * 8 * 12) + (shadow_y * 12) + mask];      
                     
                     break;
                  }
                  case k600TVL:
                  {
                     colour_mask = kShadowMasks8K600TVL[(lcd_subpixel_layout * 8 * 12) + (shadow_y * 12) + mask]; 

                     break;
                  }
                  case k800TVL:
                  {
                     colour_mask = kShadowMasks8K800TVL[(lcd_subpixel_layout * 4 * 6) + (shadow_y * 6) + mask]; 

                     break;
                  }
                  case k1000TVL:
                  {
                     colour_mask = kShadowMasks8K1000TVL[(lcd_subpixel_layout * 4 * 6) + (shadow_y * 6) + mask]; 

                     break;
                  }
                  default:
                  {
                     break;
                  }                 
               }

               break;
            }
            default:
            {
               break;
            }                 
         }

         break;
      }
      case kSlotMask:
      {
         uint slot_x = uint(floor(mod(current_position.x / kSlotMaskSizeX[(lcd_resolution * kTVLAxis) + crt_resolution], kMaxSlotSizeX)));
         uint slot_y = uint(floor(mod(current_position.y, kSlotMaskSizeY[(lcd_resolution * kTVLAxis) + crt_resolution])));

         uint mask = uint(floor(mod(current_position.x, kSlotMaskSizeX[(lcd_resolution * kTVLAxis) + crt_resolution])));

         switch(lcd_resolution)
         {
            case k1080p:
            { 
               switch(crt_resolution)
               {
                  case k300TVL:
                  { 
                     #define kMaxSlotMaskSize   4
                     #define kMaxSlotSizeY      4
                     
                     colour_mask = kSlotMasks1080p300TVL[(lcd_subpixel_layout * kMaxSlotSizeY * kMaxSlotSizeX * kMaxSlotMaskSize) + (slot_y * kMaxSlotSizeX * kMaxSlotMaskSize) + (slot_x * kMaxSlotMaskSize) + mask];      
                     
                     #undef kMaxSlotMaskSize  
                     #undef kMaxSlotSizeY   

                     break;
                  }
                  case k600TVL:
                  {
                     #define kMaxSlotMaskSize   2
                     #define kMaxSlotSizeY      4

                     colour_mask = kSlotMasks1080p600TVL[(lcd_subpixel_layout * kMaxSlotSizeY * kMaxSlotSizeX * kMaxSlotMaskSize) + (slot_y * kMaxSlotSizeX * kMaxSlotMaskSize) + (slot_x * kMaxSlotMaskSize) + mask];      
                     
                     #undef kMaxSlotMaskSize  
                     #undef kMaxSlotSizeY   

                     break;
                  }
                  case k800TVL:
                  {
                     #define kMaxSlotMaskSize   1
                     #define kMaxSlotSizeY      4

                     colour_mask = kSlotMasks1080p800TVL[(lcd_subpixel_layout * kMaxSlotSizeY * kMaxSlotSizeX * kMaxSlotMaskSize) + (slot_y * kMaxSlotSizeX * kMaxSlotMaskSize) + (slot_x * kMaxSlotMaskSize) + mask];      
                     
                     #undef kMaxSlotMaskSize  
                     #undef kMaxSlotSizeY   

                     break;
                  }
                  case k1000TVL:
                  {
                     #define kMaxSlotMaskSize   1
                     #define kMaxSlotSizeY      4

                     colour_mask = kSlotMasks1080p1000TVL[(lcd_subpixel_layout * kMaxSlotSizeY * kMaxSlotSizeX * kMaxSlotMaskSize) + (slot_y * kMaxSlotSizeX * kMaxSlotMaskSize) + (slot_x * kMaxSlotMaskSize) + mask];      
                     
                     #undef kMaxSlotMaskSize  
                     #undef kMaxSlotSizeY   

                     break;
                  }
                  default:
                  {
                     break;
                  }                 
               }

               break;
            }
            case k4K:
            {
               switch(crt_resolution)
               {
                  case k300TVL:
                  { 
                     #define kMaxSlotMaskSize   7
                     #define kMaxSlotSizeY      8

                     colour_mask = kSlotMasks4K300TVL[(lcd_subpixel_layout * kMaxSlotSizeY * kMaxSlotSizeX * kMaxSlotMaskSize) + (slot_y * kMaxSlotSizeX * kMaxSlotMaskSize) + (slot_x * kMaxSlotMaskSize) + mask];        
                     
                     #undef kMaxSlotMaskSize  
                     #undef kMaxSlotSizeY      
                     
                     break;
                  }
                  case k600TVL:
                  {
                     #define kMaxSlotMaskSize   4
                     #define kMaxSlotSizeY      6

                     colour_mask = kSlotMasks4K600TVL[(lcd_subpixel_layout * kMaxSlotSizeY * kMaxSlotSizeX * kMaxSlotMaskSize) + (slot_y * kMaxSlotSizeX * kMaxSlotMaskSize) + (slot_x * kMaxSlotMaskSize) + mask];      
                     
                     #undef kMaxSlotMaskSize  
                     #undef kMaxSlotSizeY   

                     break;
                  }
                  case k800TVL:
                  {
                     #define kMaxSlotMaskSize   3
                     #define kMaxSlotSizeY      4

                     colour_mask = kSlotMasks4K800TVL[(lcd_subpixel_layout * kMaxSlotSizeY * kMaxSlotSizeX * kMaxSlotMaskSize) + (slot_y * kMaxSlotSizeX * kMaxSlotMaskSize) + (slot_x * kMaxSlotMaskSize) + mask];      
                     
                     #undef kMaxSlotMaskSize  
                     #undef kMaxSlotSizeY   

                     break;
                  }
                  case k1000TVL:
                  {
                     #define kMaxSlotMaskSize   2
                     #define kMaxSlotSizeY      4

                     colour_mask = kSlotMasks4K1000TVL[(lcd_subpixel_layout * kMaxSlotSizeY * kMaxSlotSizeX * kMaxSlotMaskSize) + (slot_y * kMaxSlotSizeX * kMaxSlotMaskSize) + (slot_x * kMaxSlotMaskSize) + mask];      
                     
                     #undef kMaxSlotMaskSize  
                     #undef kMaxSlotSizeY   

                     break;
                  }
                  default:
                  {
                     break;
                  }                 
               }

               break;
            }
            case k8K:
            {
               switch(crt_resolution)
               {
                  case k300TVL:
                  { 
                     #define kMaxSlotMaskSize   7
                     #define kMaxSlotSizeY      6

                     colour_mask = kSlotMasks8K300TVL[(lcd_subpixel_layout * kMaxSlotSizeY * kMaxSlotSizeX * kMaxSlotMaskSize) + (slot_y * kMaxSlotSizeX * kMaxSlotMaskSize) + (slot_x * kMaxSlotMaskSize) + mask];      
                     
                     #undef kMaxSlotMaskSize  
                     #undef kMaxSlotSizeY        
                     
                     break;
                  }
                  case k600TVL:
                  {
                     #define kMaxSlotMaskSize   7
                     #define kMaxSlotSizeY      6

                     colour_mask = kSlotMasks8K600TVL[(lcd_subpixel_layout * kMaxSlotSizeY * kMaxSlotSizeX * kMaxSlotMaskSize) + (slot_y * kMaxSlotSizeX * kMaxSlotMaskSize) + (slot_x * kMaxSlotMaskSize) + mask];      
                     
                     #undef kMaxSlotMaskSize  
                     #undef kMaxSlotSizeY   

                     break;
                  }
                  case k800TVL:
                  {
                     #define kMaxSlotMaskSize   5
                     #define kMaxSlotSizeY      4

                     colour_mask = kSlotMasks8K800TVL[(lcd_subpixel_layout * kMaxSlotSizeY * kMaxSlotSizeX * kMaxSlotMaskSize) + (slot_y * kMaxSlotSizeX * kMaxSlotMaskSize) + (slot_x * kMaxSlotMaskSize) + mask];      
                     
                     #undef kMaxSlotMaskSize  
                     #undef kMaxSlotSizeY   

                     break;
                  }
                  case k1000TVL:
                  {
                     #define kMaxSlotMaskSize   4
                     #define kMaxSlotSizeY      4

                     colour_mask = kSlotMasks8K1000TVL[(lcd_subpixel_layout * kMaxSlotSizeY * kMaxSlotSizeX * kMaxSlotMaskSize) + (slot_y * kMaxSlotSizeX * kMaxSlotMaskSize) + (slot_x * kMaxSlotMaskSize) + mask];      
                     
                     #undef kMaxSlotMaskSize  
                     #undef kMaxSlotSizeY   

                     break;
                  }
                  default:
                  {
                     break;
                  }                 
               }

               break;
            }
            default:
            {
               break;
            }                 
         }

         break;
      }
#if ENABLE_BLACK_WHITE_MASKS
      case kBlackWhiteMask:
      {
         uint mask = uint(floor(mod(current_position.x, kBlackWhiteMaskSize[(lcd_resolution * kTVLAxis) + crt_resolution])));

         colour_mask = kBlackWhiteMasks[(lcd_resolution * kTVLAxis * kBGRAxis * kMaxBlackWhiteSize) + (crt_resolution * kBGRAxis * kMaxBlackWhiteSize) + (lcd_subpixel_layout * kMaxBlackWhiteSize) + mask];      

         switch(lcd_resolution)
         {
            case k1080p:
            { 
               break;
            }
            case k4K:
            {
               break;
            }
            case k8K:
            {
               break;
            }
            default:
            {
               break;
            }                 
         }

         break;
      }
#endif // ENABLE_BLACK_WHITE_MASKS
      default:
      {
         break;
      }
   }

   const float scanline_size           = output_size.y / source_size.y;

   const float3 horizontal_convergence   = float3(HCRT_RED_HORIZONTAL_CONVERGENCE, HCRT_GREEN_HORIZONTAL_CONVERGENCE, HCRT_BLUE_HORIZONTAL_CONVERGENCE);
   const float3 vertical_convergence     = float3(HCRT_RED_VERTICAL_CONVERGENCE, HCRT_GREEN_VERTICAL_CONVERGENCE, HCRT_BLUE_VERTICAL_CONVERGENCE);
   const float3 beam_sharpness           = float3(HCRT_RED_BEAM_SHARPNESS, HCRT_GREEN_BEAM_SHARPNESS, HCRT_BLUE_BEAM_SHARPNESS);
   const float3 beam_attack              = float3(HCRT_RED_BEAM_ATTACK, HCRT_GREEN_BEAM_ATTACK, HCRT_BLUE_BEAM_ATTACK);
   const float3 scanline_min             = float3(HCRT_RED_SCANLINE_MIN, HCRT_GREEN_SCANLINE_MIN, HCRT_BLUE_SCANLINE_MIN);
   const float3 scanline_max             = float3(HCRT_RED_SCANLINE_MAX, HCRT_GREEN_SCANLINE_MAX, HCRT_BLUE_SCANLINE_MAX);
   const float3 scanline_attack          = float3(HCRT_RED_SCANLINE_ATTACK, HCRT_GREEN_SCANLINE_ATTACK, HCRT_BLUE_SCANLINE_ATTACK);

   const uint channel_count            = colour_mask & 3;

   float3 scanline_colour = 0.0f.xxx;

   if(channel_count > 0)
   {
      const uint channel_0             = (colour_mask >> kFirstChannelShift) & 3;

      const float scanline_channel_0   = GenerateScanline(  channel_0,
                                                            tex_coord,
                                                            source_size.xy, 
                                                            scanline_size, 
                                                            horizontal_convergence[channel_0], 
                                                            vertical_convergence[channel_0], 
                                                            beam_sharpness[channel_0], 
                                                            beam_attack[channel_0], 
                                                            scanline_min[channel_0], 
                                                            scanline_max[channel_0], 
                                                            scanline_attack[channel_0]);

      scanline_colour =  scanline_channel_0 * kColourMask[channel_0];
   }

   if(channel_count > 1)
   {
      const uint channel_1             = (colour_mask >> kSecondChannelShift) & 3;

      const float scanline_channel_1   = GenerateScanline(channel_1,
                                                          tex_coord,
                                                          source_size.xy, 
                                                          scanline_size, 
                                                          horizontal_convergence[channel_1], 
                                                          vertical_convergence[channel_1], 
                                                          beam_sharpness[channel_1], 
                                                          beam_attack[channel_1], 
                                                          scanline_min[channel_1], 
                                                          scanline_max[channel_1], 
                                                          scanline_attack[channel_1]);

      scanline_colour += scanline_channel_1 * kColourMask[channel_1];
   }

   if(channel_count > 2)
   {
      const uint channel_2             = (colour_mask >> kThirdChannelShift) & 3;

      const float scanline_channel_2   = GenerateScanline(channel_2,
                                                          tex_coord,
                                                          source_size.xy, 
                                                          scanline_size, 
                                                          horizontal_convergence[channel_2], 
                                                          vertical_convergence[channel_2], 
                                                          beam_sharpness[channel_2], 
                                                          beam_attack[channel_2], 
                                                          scanline_min[channel_2], 
                                                          scanline_max[channel_2], 
                                                          scanline_attack[channel_2]);

      scanline_colour += scanline_channel_2 * kColourMask[channel_2];
   }

   float3 transformed_colour;

   if(HCRT_COLOUR_ACCURATE >= 1.0f)
   {
      if(HCRT_HDR >= 1.0f)
      {
         const float3 rec2020  = mul(k2020Gamuts[uint(HCRT_EXPAND_GAMUT)], scanline_colour);
         transformed_colour  = rec2020 * (HCRT_PAPER_WHITE_NITS / kMaxNitsFor2084);
      }
      else if(HCRT_OUTPUT_COLOUR_SPACE == 2.0f)
      {
         transformed_colour = mul(kXYZ_to_DCIP3, mul(k709_to_XYZ, scanline_colour));
      }
      else
      {
         transformed_colour = scanline_colour;
      }
   } 
   else
   {      
      transformed_colour = scanline_colour;
   }

   float3 gamma_corrected; 
   
   GammaCorrect(transformed_colour, gamma_corrected);

   fragment = float4(gamma_corrected, 1.0f);
}

technique SonyMegatron
{
	pass { VertexShader = PostProcessVS; PixelShader = Downsample; RenderTarget = SourceTexture; }
	pass { VertexShader = PostProcessVS; PixelShader = ColourPass; RenderTarget = SDRTexture; } 
	pass { VertexShader = PostProcessVS; PixelShader = HDRPass; RenderTarget = HDRTexture; }
	pass { VertexShader = PostProcessVS; PixelShader = SonyMegatronPass; }
}