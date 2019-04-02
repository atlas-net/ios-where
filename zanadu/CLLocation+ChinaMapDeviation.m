//
//  CLLocation+ChinaMapDeviation.m
//
//  Created by Maxime on 5/12/13.
//  Copyright (c) 2013 Maxime. All rights reserved.
//

#import "CLLocation+ChinaMapDeviation.h"
#import "BPRegion.h"

static double *longitudeDeviationCoeficients = nil;
static double longitudeDeviationCoeficientsCount = 500;
static double longitudeDeviationN = 11084;
static double longitudeDeviationRangeX = 55.405;
static double longitudeDeviationOffsetX = 78.455;

static double *latitudeDeviationCoeficients = nil;
static double latitudeDeviationCoeficientsCount = 100;
static double latitudeDeviationN = 6651;
static double latitudeDeviationRangeX = 33.24;
static double latitudeDeviationOffsetX = 20.225;
static BPRegion *china = nil;

@interface CLLocation (PrivateMethods)
-(void) fillLongitudeDeviationCoeficients;
-(void) fillLatitudeDeviationCoeficients;
@end

@implementation CLLocation (CorrectDeviation)

-(void) fillLongitudeDeviationCoeficients {
    if (longitudeDeviationCoeficients!=nil) { return; }

    double *coefs = malloc(longitudeDeviationCoeficientsCount * sizeof(double));

    double data[] = {0.369187, -0.11326, 0.0126899, 0.0542206, 0.0212344, -0.0394036, \
        -0.0032253, -0.00224793, -0.00143236, -0.00038908, -0.00134441, \
        -0.000246341, -0.00135907, -0.000360279, -0.0018282, -0.000361758, \
        -0.00322032, -0.00100907, -0.0137237, 0.00526789, 0.00322866, \
        0.00114827, 0.00153466, 0.000256152, 0.00119467,
        3.67236*pow(10,-6), 0.000812329, 0.000120397, 0.000437886, 0.000183615, \
        0.000333085, 0.0000279559, 0.000426747, -0.000142544, 0.000429467, \
        -0.00013228, 0.000282542, -0.0000340537, 0.000178317, -0.0000633329, \
        0.000245482, -0.000224438, 0.000357311, -0.00031238, 0.000329653, \
        -0.000260479, 0.000222733, -0.000237218, 0.000259252, -0.000438053, \
        0.000522532, -0.000849126, 0.000881269, -0.00139451, 0.00159785, \
        -0.00631603, -0.00300369, 0.00161106, -0.000826378, 0.000865802, \
        -0.000566594, 0.000581233, -0.000405593, 0.000384735, -0.000280501, \
        0.000263398, -0.000223455, 0.000211942, -0.000215156, 0.000195712, \
        -0.000220935, 0.000179869, -0.000211822, 0.000149592, -0.000192316, \
        0.000104788, -0.00016901, 0.000084323, -0.000178384, 0.0000917802, \
        -0.000203288, 0.0000968072, -0.000209943, 0.0000710955, -0.000187587, \
        0.0000343761, -0.000182477, 0.0000336745, -0.000220653, 0.0000626143, \
        -0.000264116, 0.0000591754, -0.000261701,
        7.1884*pow(10,-6), -0.000243514, -0.0000213429, -0.000281773, \
        0.000014272, -0.000382012, 0.0000501743, -0.000450479,
        3.83833*pow(10,-6), -0.000456935, -0.0000921996, -0.000548418, \
        -0.0000935041, -0.000910142, 0.000057956, -0.0016522, 0.0000152476, \
        -0.0050466, 0.0043411, 0.0030465, 0.000445211, 0.00124658, \
        0.0000659231, 0.000852441, -4.0691*pow(10,-6), 0.000600634, 0.0000654814, \
        0.000392656, 0.000100811, 0.000315994, 0.0000500242, 0.000315084,
        5.43008*pow(10,-7), 0.000286418, 0.0000131267, 0.000216959, 0.0000442432, \
        0.000181455, 0.0000374035, 0.000183609,
        6.08049*pow(10,-6), 0.000187161, -5.45908*pow(10,-7), 0.000156311, \
        0.0000199018, 0.000123346, 0.0000293381, 0.000120802,
        7.32042*pow(10,-6), 0.000132719, -7.66264*pow(10,-6), 0.000123542,
        5.59781*pow(10,-6), 0.0000981927, 0.0000171517, 0.0000888745,
        7.09148*pow(10,-6), 0.0000985561, -0.000010966, 0.000103456, \
        -7.80091*pow(10,-6), 0.0000865247, 7.89175*pow(10,-6), 0.000069273,
        6.35014*pow(10,-6), 0.0000756957, -8.21086*pow(10,-6), 0.000084466, \
        -0.0000134109, 0.0000738174, -3.85052*pow(10,-6), 0.0000613079,
        2.55881*pow(10,-6), 0.0000550873, -8.37662*pow(10,-6), 0.0000718555, \
        -0.0000163907, 0.0000710323, -0.0000129522, 0.0000586533, \
        -3.73025*pow(10,-6), 0.0000485504, -5.27255*pow(10,-6), 0.0000580946, \
        -0.0000187664, 0.0000633552, -0.0000190145, 0.0000536511, \
        -9.37345*pow(10,-6), 0.000042858, -7.079*pow(10,-6), 0.0000478564, \
        -0.0000186011, 0.000054644, -0.0000241947, 0.0000531798, \
        -0.0000153756, 0.000043798, -9.66857*pow(10,-6), 0.0000403417, \
        -0.0000170684, 0.0000470098, -0.0000275036, 0.0000511361, \
        -0.0000259987, 0.000041187, -0.000015798, 0.0000349976, \
        -0.0000148011, 0.0000395976, -0.0000275218, 0.0000484753, \
        -0.0000291378, 0.0000438381, -0.0000215755, 0.0000331215, \
        -0.0000196411, 0.0000340886, -0.0000260071, 0.0000433228, \
        -0.000031989, 0.0000438446, -0.0000293453, 0.0000330994, \
        -0.0000215918, 0.000031323, -0.0000241732, 0.0000365552, \
        -0.0000344775, 0.0000404521, -0.0000374166, 0.000037404, \
        -0.0000291993, 0.0000275725, -0.0000260016, 0.0000326107, \
        -0.0000372681, 0.0000415656, -0.0000425157, 0.0000403817, \
        -0.0000356436, 0.0000276516, -0.0000279176, 0.0000251464, \
        -0.0000362352, 0.000036908, -0.0000467737, 0.0000410395, \
        -0.0000453667, 0.0000310629, -0.0000324971, 0.0000244399, \
        -0.0000358057, 0.0000316459, -0.000049446, 0.0000419337, \
        -0.0000528057, 0.0000366071, -0.0000438623, 0.0000262526, \
        -0.000036201, 0.0000243944, -0.0000476651, 0.0000387201, \
        -0.0000591413, 0.0000403009, -0.0000565441, 0.0000280752, \
        -0.0000434274, 0.0000235392, -0.0000501914, 0.0000333482, \
        -0.0000656535, 0.0000436863, -0.0000691971, 0.0000364005, \
        -0.0000556904, 0.0000225534, -0.0000514751, 0.0000269613, \
        -0.00006756, 0.0000441731, -0.0000813443, 0.000041896, -0.0000784235, \
        0.0000302028, -0.0000611805, 0.0000265199, -0.0000702644, \
        0.0000437588, -0.000092325, 0.0000537334, -0.0000919398, \
        0.0000401907, -0.0000761014, 0.0000239709, -0.0000766387, \
        0.0000353035, -0.000102175, 0.0000565667, -0.000117478, 0.0000529286, \
        -0.000103879, 0.0000322575, -0.0000935224, 0.0000303173, \
        -0.000114691, 0.0000583366, -0.000145762, 0.0000711511, -0.000144037, \
        0.0000474749, -0.000124375, 0.0000314531, -0.000137258, 0.0000561043, \
        -0.000183824, 0.0000912002, -0.000211041, 0.000079007, -0.000186733, \
        0.0000218876, -0.000190489, 0.0000534396, -0.000255813, 0.000120935, \
        -0.000342523, 0.000148099, -0.000364316, 0.0000950685, -0.000357723, \
        0.0000740501, -0.000485805, 0.000200841, -0.000842227, 0.00044395, \
        -0.0012042, 0.000507051, -0.00250657, 0.00105383, 0.00670895, \
        -0.00051195, 0.00172243, -0.000447781, 0.000952466, -0.000287057, \
        0.000624861, -0.0000995574, 0.000399313, -0.0000545579, 0.000354643, \
        -0.000111406, 0.00036082, -0.000122632, 0.000302697, -0.0000704851, \
        0.000216666, -0.0000348043, 0.000196157, -0.0000310741, 0.000204555, \
        -0.0000660606, 0.00020109, -0.0000513123, 0.000157227, -0.0000159993, \
        0.000125601, -0.0000134838, 0.000133934, -0.0000388693, 0.000145446, \
        -0.0000438549, 0.00012932, -0.000020919, 0.0000987094, \
        -7.09995*pow(10,-6), 0.0000966919, -0.0000198277, 0.000109269, \
        -0.0000339553, 0.000109349, -0.0000249326, 0.000086065, \
        -5.9088*pow(10,-6), 0.0000738523, -7.8403*pow(10,-6), 0.0000846447, \
        -0.0000236442, 0.000091778, -0.0000238223, 0.0000811491, \
        -7.41976*pow(10,-6), 0.0000608082, -1.40334*pow(10,-6), 0.0000558442, \
        -0.0000178954, 0.0000833436, -0.0000219416, 0.0000778138, \
        -0.0000159061, 0.0000598699, -2.04312*pow(10,-6), 0.0000539548, \
        -6.95124*pow(10,-6), 0.0000617395, -0.0000184184, 0.0000682707, \
        -0.0000174559, 0.0000593966, -2.93043*pow(10,-6), 0.0000480899, \
        -7.78578*pow(10,-7), 0.0000484539, -0.0000121994, 0.0000593119, \
        -0.0000156623, 0.0000564409, -6.92516*pow(10,-6), 0.0000456529, \
        -8.57663*pow(10,-7), 0.0000424459, -7.4643*pow(10,-6), 0.0000479763, \
        -0.0000131679, 0.0000518404, -8.78885*pow(10,-6), 0.0000449177, \
        -4.30127*pow(10,-7), 0.0000365422, -3.8323*pow(10,-6), 0.0000401823, \
        -8.18794*pow(10,-6), 0.000044308, -0.0000110854, 0.0000445243, \
        -4.18029*pow(10,-6), 0.0000343069, -3.27331*pow(10,-7), 0.0000335318, \
        -5.28925*pow(10,-6), 0.0000418481, -0.0000120572, 0.0000431433, \
        -7.01398*pow(10,-6), 0.0000344503, -3.68348*pow(10,-6), 0.0000322625, \
        -4.89135*pow(10,-6), 0.0000373524, -0.0000133273, 0.0000496696,
        1.37313*pow(10,-6), 0.0000335462, 2.18747*pow(10,-6), 0.000025462,
        3.43517*pow(10,-6), 0.0000281516, -2.55843*pow(10,-6), 0.0000358236, \
        -7.6473*pow(10,-6), 0.0000360352, -2.94191*pow(10,-6), 0.0000283102, 
        3.97735*pow(10,-7), 0.0000250387, -8.11342*pow(10,-7), 0.0000300811, \
        -7.04135*pow(10,-6), 0.0000334942, -6.74124*pow(10,-6), 0.0000271314, \
        -1.08247*pow(10,-6), 0.0000245343, 
        5.85499*pow(10,-7), 0.0000237421, -2.42147*pow(10,-6), 0.0000299402, \
        -7.59805*pow(10,-6), 0.0000290495, -2.27441*pow(10,-6), 0.0000221614, 
        1.5134*pow(10,-6), 0.0000219924, -7.40825*pow(10,-7), 0.0000273967, \
        -4.37081*pow(10,-6), 0.0000282576, -3.8868*pow(10,-6), 0.0000240228, 
        1.03083*pow(10,-6), 0.0000183727, -2.64009*pow(10,-7), 0.0000239823, \
        -2.93603*pow(10,-6), 0.000025331, -5.14558*pow(10,-6), 0.0000258636, 
        2.56793*pow(10,-7), 0.0000214312, -3.14119*pow(10,-7), 0.0000197157, \
        -1.45939*pow(10,-6), 0.0000243798, -4.56689*pow(10,-6), 0.0000236006, \
        -9.98062*pow(10,-7), 0.0000194956};
    for (int i=0;i<longitudeDeviationCoeficientsCount;i++) {
        coefs[i] = data[i];
    }
    longitudeDeviationCoeficients = coefs;
}

-(void) fillLatitudeDeviationCoeficients {
    if (latitudeDeviationCoeficients!=nil) { return; }

    double *coefs = malloc(latitudeDeviationCoeficientsCount * sizeof(double));
    
    double data[] = {-0.0261317, -0.109996, -0.0155823, 0.031569, 0.00696625, 0.00228456, \
        0.000844341, 0.000853768, -0.000995046, 0.000310576, -0.00490081, \
        -0.00321087, 0.00642828, 0.000332075, 0.00205018, 0.000150784, \
        0.00115235, 0.000100981, 0.000744611, 0.000058565, 0.00051447, \
        -1.94572*pow(10,-6), 0.000376192, -0.0000243837, 0.000229146, \
        -0.0000611643, 0.000137193, -0.000121672, 0.0000166001, -0.000208218, \
        -0.000189172, -0.000407356, -0.000874815, -0.00422415, 0.00191545, \
        0.000606974, 0.000637015, 0.000294882, 0.000405763, 0.000205625, \
        0.000310265, 0.000146241, 0.000253337, 0.000120604, 0.000212375, \
        0.0000991347, 0.000183631, 0.0000856623, 0.000167409, 0.0000729607, \
        0.000141208, 0.0000656807, 0.000132105, 0.0000565689, 0.000118763, \
        0.0000516198, 0.000109856, 0.0000500978, 0.0000968809, 0.0000402533, \
        0.0000962025, 0.0000403901, 0.0000826892, 0.0000375213, 0.0000796911, \
        0.0000349581, 0.0000745531, 0.000029846, 0.000069855, 0.0000316422, \
        0.0000648851, 0.0000252855, 0.0000617505, 0.000027221, 0.0000570307, \
        0.0000243587, 0.0000542426, 0.0000228639, 0.0000523948, 0.000020483, \
        0.0000468267, 0.0000216549, 0.0000476513, 0.0000167646, 0.0000431478, \
        0.0000180996, 0.0000410668, 0.0000177424, 0.0000387281, 0.0000160124, \
        0.0000398926, 0.0000144214, 0.0000345505, 0.0000138505, 0.0000338709, \
        0.0000133423, 0.000032041, 0.0000114379, 0.0000325401, 0.0000144027};
    for (int i=0;i<latitudeDeviationCoeficientsCount;i++) {
        coefs[i] = data[i];
    }
    latitudeDeviationCoeficients = coefs;
}

-(double) longitudeDeviation {
    [self fillLongitudeDeviationCoeficients];
    double latitude = self.coordinate.latitude;
    double longitude = self.coordinate.longitude;
    double longitudeDeviation = longitudeDeviationCoeficients[0];
    double r = (M_PI/longitudeDeviationN) *(longitudeDeviationN/longitudeDeviationRangeX);
    for (int i=1;i<longitudeDeviationCoeficientsCount;i++) {
        longitudeDeviation += 2*longitudeDeviationCoeficients[i]*cos(r*i*(longitude-longitudeDeviationOffsetX));
    }
    longitudeDeviation = longitudeDeviation * (1/sqrt(longitudeDeviationN));
    double offset = 0.0334888
                    + 0.00113778 * latitude
                    - 0.0000272672 * pow(latitude,2)
                    + 2.90877* pow(10,-7) * pow(latitude,3)
                    - 9.25695* pow(10,-10) * pow(latitude, 4)
                    - 0.0013772 * longitude
                    + 0.0000173189 * pow(longitude,2)
                    - 8.62868 * pow(10,-8) * pow(longitude,3)
                    + 1.36857 * pow(10,-10) * pow(longitude, 4)
                    - 8.35551 * pow(10,-6) * latitude * longitude
                    + 1.70615 * pow(10,-9) * pow(latitude,2) * pow(longitude,2)
                    - 1.40666 * pow(10,-13) * pow(latitude,3) * pow(longitude,3)
                    + 4.0761 * pow(10,-18) * pow(latitude,4) * pow(longitude,4);
    longitudeDeviation = longitudeDeviation + offset;
    return longitudeDeviation;
}

-(double) latitudeDeviation {
    [self fillLatitudeDeviationCoeficients];
    double latitude = self.coordinate.latitude;
    double longitude = self.coordinate.longitude;
    double latitudeDeviation = latitudeDeviationCoeficients[0];
    double r = (M_PI/latitudeDeviationN) *(latitudeDeviationN/latitudeDeviationRangeX);
    for (int i=1;i<latitudeDeviationCoeficientsCount;i++) {
        latitudeDeviation += 2*latitudeDeviationCoeficients[i]*cos(r*i*(latitude-latitudeDeviationOffsetX));
    }
    latitudeDeviation = latitudeDeviation * (1/sqrt(latitudeDeviationN));
    double offset = - 0.00666525
                    - 0.000305238 * latitude
                    + 0.0000312816 * pow(latitude, 2)
                    - 7.01206 * pow(10,-7) * pow(latitude, 3)
                    + 5.09878 * pow(10,-9) * pow(latitude, 4)
                    + 0.000270959 * longitude
                    - 1.00155 * pow(10,-6)  * pow(longitude,2)
                    - 2.17168 * pow(10,-9)  * pow(longitude,3)
                    + 1.93365 * pow(10,-11) * pow(longitude,4)
                    - 8.51496 * pow(10,-6)  * latitude * longitude
                    + 1.62305 * pow(10,-9)  * pow(latitude,2) * pow(longitude,2)
                    - 1.54638 * pow(10,-13) * pow(latitude,3) * pow(longitude,3)
                    + 5.6414  * pow(10,-18) * pow(latitude,4) * pow(longitude,4);
    latitudeDeviation = latitudeDeviation + offset;
    return latitudeDeviation;
}

-(CLLocationCoordinate2D) deviatedCoordinates {
    CLLocationCoordinate2D coordinates = self.coordinate;
    
    if (china==nil) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"china" withExtension:@"kml"];
        china = [BPRegion regionWithContentsOfURL:url];
    }
    
    if ([china containsCoordinate:coordinates]) {
        coordinates.longitude = coordinates.longitude + [self longitudeDeviation];
        coordinates.latitude = coordinates.latitude + [self latitudeDeviation];
    }
    
    return coordinates;
}

-(CLLocationCoordinate2D) undeviatedCoordinates {
    CLLocationCoordinate2D coordinates = self.coordinate;
    
    if (china==nil) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"china" withExtension:@"kml"];
        china = [BPRegion regionWithContentsOfURL:url];
    }
    
    if ([china containsCoordinate:coordinates]) {
        coordinates.longitude = coordinates.longitude - [self longitudeDeviation];
        coordinates.latitude = coordinates.latitude - [self latitudeDeviation];
    }
    
    return coordinates;
}

@end