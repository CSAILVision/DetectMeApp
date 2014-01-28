//
//  UIImage+HOG.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 26/02/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "UIImage+HOG.h"
#import "UIImage+Resize.h"
#import "UIImage+Rotation.h"

#define PI 3.14159265
#define eps 0.00001
//#define pixelsPerHogCell 6 //pixels per block


double uu[9] = {1.0000, //non oriented HOG representants, sweeping from (1,0) to (-1,0).
    0.9397,
    0.7660,
    0.500,
    0.1736,
    -0.1736,
    -0.5000,
    -0.7660,
    -0.9397};
double vv[9] = {0.0000,
    0.3420,
    0.6428,
    0.8660,
    0.9848,
    0.9848,
    0.8660,
    0.6428,
    0.3420};

static inline double min(double x, double y) { return (x <= y ? x : y); }
static inline double max(double x, double y) { return (x <= y ? y : x); }

static inline int min_int(int x, int y) { return (x <= y ? x : y); }
static inline int max_int(int x, int y) { return (x <= y ? y : x); }


@implementation HogFeature

@synthesize features = _features;
@synthesize dimensionOfHogFeatures = _dimensionOfHogFeatures;


- (void) printFeaturesOnScreen
{
    
    for(int y=0; y<self.numBlocksY; y++){
        for(int x=0; x<self.numBlocksX; x++){
            for(int f = 0; f<self.numFeaturesPerBlock; f++){
                printf("%f ", self.features[y + x*self.numBlocksY + f*self.numBlocksX*self.numBlocksY]);
                if(f==17 || f==26) printf("  |  ");
            }
            printf("\n");
        }
        printf("\n*************************************************************************\n");
    }
    
}


- (void) dealloc
{
    free(self.features);
    free(self.dimensionOfHogFeatures);
}

@end


@implementation UIImage (HOG)



- (HogFeature *) obtainHogFeatures
{
    HogFeature *hog = [[HogFeature alloc] init];

    //correct the orientation diference between UIImage and the underlying CGImage to make them coincide
    UIImage *correctedImage = [self fixOrientation];
    
    // Inizialization
    CGImageRef imageRef = correctedImage.CGImage;
    
    // Get the image in bits: Create a context and draw the image there to get the image in bits
    NSUInteger width = CGImageGetWidth(imageRef); //#pixels width
    NSUInteger height = CGImageGetHeight(imageRef); //#pixels height
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * width;
    int bitsPerComponent = 8;
    UInt8 *im = (UInt8 *)malloc(height * width * 4);
        
    CGContextRef contextImage = CGBitmapContextCreate(im, width, height,
                                                      bitsPerComponent, bytesPerRow, colorSpace,
                                                      kCGImageAlphaPremultipliedLast| kCGBitmapByteOrder32Big );
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(contextImage, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(contextImage);
    
    int dims[2] = {height, width};

    int blocks[2]; //HOG features size
    blocks[0] = (int)round((double)dims[0]/(double)pixelsPerHogCell); //HOG Cell of (pixelsPerHogCell)x(pixelsPerHogCell) pixels
    blocks[1] = (int)round((double)dims[1]/(double)pixelsPerHogCell);
    
    double *hist = (double *) calloc(blocks[0]*blocks[1]*18,sizeof(double)); //histogram for each block of the HOG with its 18 histograms channel per each.
    double *norm = (double *) calloc(blocks[0]*blocks[1],sizeof(double)); //pointer to end value of histogram
    
    //define hog dimensions
    hog.numBlocksY = max(blocks[0]-2, 0); // do not take into account the strip of blocks surrounding the image
    hog.numBlocksX = max(blocks[1]-2, 0);
    hog.numFeaturesPerBlock = 18 + 9 + 4; // 18 oriented features + 9 unoriented features + 4 texture features
    hog.totalNumberOfFeatures = hog.numBlocksY*hog.numBlocksX*hog.numFeaturesPerBlock;
    
    hog.features = malloc(hog.totalNumberOfFeatures*sizeof(double)); // pointer to the HOG features (this is the return value!)
    double *feat = hog.features;
    int visible[2]; // Each visible pixel (ie taking into account the round made in defining blocks size and neglecting the edge pixels)
    visible[0] = blocks[0]*pixelsPerHogCell;
    visible[1] = blocks[1]*pixelsPerHogCell;
    
    
    for (int y = 1; y < visible[0]-1; y++) { //Take care to begin with the first one and end before the last one: not calculating the gradient at the edge
        for (int x = 1; x < visible[1]-1; x++) {
            
            UInt8 *s = 0; //pointer to the image pixel
            double dx, dy, v, dx2, dy2, v2, dx3, dy3, v3;

            s = im + min_int(x, dims[1]-2)*4 + min_int(y, dims[0]-2)*dims[1]*4; //pointer to the image pixel, column-major matrix structure
            
            // first color channel
            dx = (double)*(s+4) - *(s-4);
            dy = (double)*(s+dims[1]*4) - *(s-dims[1]*4);
            v = dx*dx + dy*dy;
            
            // second color channel
            s++;
            dx2 = (double)*(s+4) - *(s-4);
            dy2 = (double)*(s+dims[1]*4) - *(s-dims[1]*4);
            v2 = dx2*dx2 + dy2*dy2;
            
            // third color channel
            s++;
            dx3 = (double)*(s+4) - *(s-4);
            dy3 = (double)*(s+dims[1]*4) - *(s-dims[1]*4);
            v3 = dx3*dx3 + dy3*dy3;
            
            
            // pick channel with strongest gradient
            if (v2 > v) {
                v = v2;
                dx = dx2;
                dy = dy2;
            }
            if (v3 > v) {
                v = v3;
                dx = dx3;
                dy = dy3;
            }
            
            // snap to one of 18 oriented HOG channels
            double best_dot = 0; //best dot product achieved
            int best_o = 0; //result will belong to [0,17] and its the mappig to the HOG representant
            for (int o = 0; o < 9; o++) {
                double dot = uu[o]*dx + vv[o]*dy; //dot product between the candidate (dx,dy) and one of the 18 orientation profiles (uu[o],vv[o])
                if (dot > best_dot) {
                    best_dot = dot;
                    best_o = o;
                } else if (-dot > best_dot) { //look fot the opposite orientation
                    best_dot = -dot;
                    best_o = o+9;
                }
            }
            
            
            // Now the histogram value is computed, it is added to the for hog features around the pixel and proportionally weighted.
            double xp = ((double)x + 0.5)/(double)pixelsPerHogCell - 0.5;
            double yp = ((double)y + 0.5)/(double)pixelsPerHogCell - 0.5;
            int ixp = (int)floor(xp); //index of the HOG feature in *hist
            int iyp = (int)floor(yp);
            double vx0 = xp - ixp; // decimal part of xp. Use to ponderate the strength of the vote to the gradient
            double vy0 = yp - iyp;
            double vx1 = 1.0 - vx0;
            double vy1 = 1.0 - vy0;
            v = sqrt(v); //strongest gradient (the selected) modulus
            
            //The surroundings blocks are 5:(0,0);(1,0);(0,1);(-1,0);(0,-1)
            if (ixp >= 0 && iyp >= 0) {
                *(hist + ixp*blocks[0] + iyp + best_o*blocks[0]*blocks[1]) +=
                vx1*vy1*v; //weighted depending
            }
            
            if (ixp+1 < blocks[1] && iyp >= 0) {
                *(hist + (ixp+1)*blocks[0] + iyp + best_o*blocks[0]*blocks[1]) +=
                vx0*vy1*v;
            }
            
            if (ixp >= 0 && iyp+1 < blocks[0]) {
                *(hist + ixp*blocks[0] + (iyp+1) + best_o*blocks[0]*blocks[1]) +=
                vx1*vy0*v;
            }
            
            if (ixp+1 < blocks[1] && iyp+1 < blocks[0]) {
                *(hist + (ixp+1)*blocks[0] + (iyp+1) + best_o*blocks[0]*blocks[1]) +=
                vx0*vy0*v;
            }
        }
    }
    
    // norm calculation: compute energy in each block by summing over orientations
    for (int o = 0; o < 9; o++) { //iteration over orientations
        double *src1 = hist + o*blocks[0]*blocks[1];
        double *src2 = hist + (o+9)*blocks[0]*blocks[1]; //same orientation, opposite direction
        double *dst = norm; //norm is a pointer to a blocks[0]*blocks[1] memmory mapping. dst will iterate through it.
        double *end = norm + blocks[1]*blocks[0];
        while (dst < end) { //iteration over pixels for the selected HOG channel (non oriented)
            *(dst++) += (*src1 + *src2) * (*src1 + *src2);
            src1++;
            src2++;
        }
    }
    
    // Normalization of each block of cells
    for (int x = 0; x < hog.numBlocksX; x++) {
        for (int y = 0; y < hog.numBlocksY; y++){
            
            double *dst = feat + x*hog.numBlocksY + y;
            double *src, *p, n1, n2, n3, n4;
            
            p = norm + (x+1)*blocks[0] + y+1; //norm pointer
            n1 = 1.0 / sqrt(*p + *(p+1) + *(p+blocks[0]) + *(p+blocks[0]+1) + eps); //normalization value
            p = norm + (x+1)*blocks[0] + y;
            n2 = 1.0 / sqrt(*p + *(p+1) + *(p+blocks[0]) + *(p+blocks[0]+1) + eps);
            p = norm + x*blocks[0] + y+1;
            n3 = 1.0 / sqrt(*p + *(p+1) + *(p+blocks[0]) + *(p+blocks[0]+1) + eps);
            p = norm + x*blocks[0] + y;
            n4 = 1.0 / sqrt(*p + *(p+1) + *(p+blocks[0]) + *(p+blocks[0]+1) + eps);
            
            double t1 = 0;
            double t2 = 0;
            double t3 = 0;
            double t4 = 0;
            
            // contrast-sensitive features
            src = hist + (x+1)*blocks[0] + (y+1);
            for (int o = 0; o < 18; o++) //looping over the different channels of
            {
                double h1 = min(*src * n1, 0.2); 
                double h2 = min(*src * n2, 0.2);
                double h3 = min(*src * n3, 0.2);
                double h4 = min(*src * n4, 0.2);
                *dst = 0.5 * (h1 + h2 + h3 + h4);
                t1 += h1;
                t2 += h2;
                t3 += h3;
                t4 += h4;
                dst += hog.numBlocksY*hog.numBlocksX;
                src += blocks[0]*blocks[1];
            }
            
            // contrast-insensitive features
            src = hist + (x+1)*blocks[0] + (y+1);
            for (int o = 0; o < 9; o++)
            {
                double sum = *src + *(src + 9*blocks[0]*blocks[1]); //take also the opposite direction in consideration
                double h1 = min(sum * n1, 0.2);
                double h2 = min(sum * n2, 0.2);
                double h3 = min(sum * n3, 0.2);
                double h4 = min(sum * n4, 0.2);
                *dst = 0.5 * (h1 + h2 + h3 + h4);
                dst += hog.numBlocksY*hog.numBlocksX;
                src += blocks[0]*blocks[1];
            }
            
            // texture features
            *dst = 0.2357 * t1;
            dst += hog.numBlocksY*hog.numBlocksX;
            *dst = 0.2357 * t2;
            dst += hog.numBlocksY*hog.numBlocksX;
            *dst = 0.2357 * t3;
            dst += hog.numBlocksY*hog.numBlocksX;
            *dst = 0.2357 * t4;
            
        }
    }
    
    
    free(hist);
    free(norm);
    free(im);

    return hog;
}



- (int *) obtainDimensionsOfHogFeatures
{
    
    UIImage *correctedImage = [self fixOrientation];
    CGImageRef imageRef = correctedImage.CGImage;
    int *hogSize = malloc(3*sizeof(int));
    
    // Get the image in bits: Create a context and draw the image there to get the image in bits
    NSUInteger width = CGImageGetWidth(imageRef); //#pixels width
    NSUInteger height = CGImageGetHeight(imageRef); //#pixels height
    
    int dims[2] = {height, width};
    
    int blocks[2]; //HOG features size
    blocks[0] = (int)round((double)dims[0]/(double)pixelsPerHogCell); //define block size for computing HOG. HOG Cell of (pixelsPerHogCell)x(pixelsPerHogCell)
    blocks[1] = (int)round((double)dims[1]/(double)pixelsPerHogCell);
    
    //define hog dimensions
    hogSize[0] = max(blocks[0]-2, 0); // Take out a strip of pixels of the boundaries of the image
    hogSize[1] = max(blocks[1]-2, 0);
    hogSize[2] = 18 + 9 + 4; // 18 oriented features + 9 unoriented features + 4 texture features + 1 truncation feature
    
    return hogSize;
}



- (UIImage *) convertToHogImage
{
    HogFeature *hog = [self obtainHogFeatures];
    int dimensions[3] = {hog.numBlocksY, hog.numBlocksX, hog.numFeaturesPerBlock};
    UIImage *image = [UIImage hogImageFromFeatures:hog.features withSize:dimensions];
    return(image);
}



+ (UIImage *) hogImageFromFeatures:(double *)hogFeatures withSize:(int *)blocks
{
    int pix = 12;
    
    UInt8 *imageBuffer = calloc(pix*pix*blocks[1]*blocks[0]*4,sizeof(UInt8)); //4 referring to the number of channels present in a RGB image
    double *f = malloc(9*sizeof(double));
    
    for (int x=0; x<blocks[1]; x++){
        for (int y=0; y<blocks[0]; y++){
            for (int i=0; i<9; i++){  //Just plot of the unoriented features
                f[i] = hogFeatures[y + x*blocks[0] + blocks[1]*blocks[0]*(i+18)]; // for each block, we store in *f the features sequentially
            }
            [UIImage blockPicture:f :imageBuffer :pix :x :y :blocks[1] :blocks[0]];
        }
    }
    
    CGContextRef context = CGBitmapContextCreate(imageBuffer, //data
                                                 blocks[1]*pix, //width
                                                 blocks[0]*pix, //height
                                                 8, //bits per component
                                                 blocks[1]*pix*4, //bytes per row
                                                 CGColorSpaceCreateDeviceRGB(),
                                                 kCGImageAlphaPremultipliedLast ); //bitmap info
    
    CGImageRef ima = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    UIImage *image = [UIImage imageWithCGImage:ima scale:1.0 orientation:UIImageOrientationUp];
    free(imageBuffer);
    free(f);
    CGImageRelease(ima);
    return(image);
}

+ (UIImage *) hogImageFromFeature:(HogFeature *)hogFeature
{
    int pix = 12;
    int blocks[3] = {hogFeature.numBlocksY, hogFeature.numBlocksX, hogFeature.numFeaturesPerBlock};
    UInt8 *imageBuffer = calloc(pix*pix*blocks[1]*blocks[0]*4,sizeof(UInt8)); //4 referring to the number of channels present in a RGB image
    double *f = malloc(9*sizeof(double));
    
    for (int x=0; x<blocks[1]; x++){
        for (int y=0; y<blocks[0]; y++){
            for (int i=0; i<9; i++){  //Just plot of the unoriented features
                f[i] = hogFeature.features[y + x*blocks[0] + blocks[1]*blocks[0]*(i+18)]; // for each block, we store in *f the features sequentially
            }
            [UIImage blockPicture:f :imageBuffer :pix :x :y :blocks[1] :blocks[0]];
        }
    }
    
    CGContextRef context = CGBitmapContextCreate(imageBuffer, //data
                                                 blocks[1]*pix, //width
                                                 blocks[0]*pix, //height
                                                 8, //bits per component
                                                 blocks[1]*pix*4, //bytes per row
                                                 CGColorSpaceCreateDeviceRGB(),
                                                 kCGImageAlphaPremultipliedLast ); //bitmap info
    
    CGImageRef ima = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    UIImage *image = [UIImage imageWithCGImage:ima scale:1.0 orientation:UIImageOrientationUp];
    CGImageRelease(ima);
    free(imageBuffer);
    free(f);
    return(image);
    
}


+ (void)blockPicture:(double *)features // compute the block picture for a block of HOG
                    :(UInt8 *)im //Image where to store the results
                    :(int)bs //pixels per block
                    :(int)x //x position of the block
                    :(int)y //y position of the block
                    :(int)blockw // block sizes width and height
                    :(int)blockh
{
    int HOG_CONTRAST = 1;
    
    for (int i=0; i<bs; i++) {
        for (int j=0; j<bs; j++) {
            
            if (i==(round((double)bs/2))) { // if we are in the y dimension center of the HOG image block
                if(features[0] > 0.0)
                {
                    im[x*bs*4 + y*blockw*bs*bs*4 + i*4 + j*4*bs*blockw] += round(255*(*(features)))*HOG_CONTRAST ;
                    im[x*bs*4 + y*blockw*bs*bs*4 + i*4 + j*4*bs*blockw + 1 ] += round(255*(*(features)))*HOG_CONTRAST ;
                    im[x*bs*4 + y*blockw*bs*bs*4 + i*4 + j*4*bs*blockw + 2 ] +=  round(255*(*(features)))*HOG_CONTRAST ;
                }
            }
            
            for (int o=1; o<9; o++) {
                if(features[o] > 0.0)
                {
                    //if it matches the angle of the corresponding feature, draw there with its intensity
                    if (j == round( (-tan(-o*PI*20/180+PI/2) * (i-round((double)bs/2)) + round((double)bs/2) )))
                    { 
                        im[x*bs*4 + y*blockw*bs*bs*4 + i*4 + j*4*bs*blockw] += round(255*(*(features + o)))*HOG_CONTRAST ;
                        im[x*bs*4 + y*blockw*bs*bs*4 + i*4 + j*4*bs*blockw + 1] += round(255*(*(features + o)))*HOG_CONTRAST ;
                        im[x*bs*4 + y*blockw*bs*bs*4 + i*4 + j*4*bs*blockw + 2] += round(255*(*(features + o)))*HOG_CONTRAST ;
                    }
                }else HOG_CONTRAST = 10; //a negative feature means we are visualizing a template model
            }
            im[x*bs*4 + y*blockw*bs*bs*4 + i*4 + j*4*bs*blockw + 3] = 255;
        }
    }
}


+ (HogFeature *) scaleHog:(HogFeature *)originalHog to:(int)scale for:(int)numScalesPerOctave;
{
    
//    if(scale == 0) return originalHog;
//    http://stackoverflow.com/questions/9570895/image-downscaling-algorithm
    
    int heights[10] = {48,45,42,39,36,34,31,29,27,25};
    int widths[10] = {36,33,31,29,27,25,23,21,20,18};

    int newHeight = heights[scale];
    int newWidth = widths[scale];

    int height = originalHog.numBlocksY;
    int width = originalHog.numBlocksX;
    
    
    //new hog
    HogFeature *scaledHog = [[HogFeature alloc] init];
    scaledHog.numBlocksX = newWidth;
    scaledHog.numBlocksY = newHeight;
    scaledHog.numFeaturesPerBlock = 31;
    scaledHog.features = (double *) malloc(newWidth*newHeight*31*sizeof(double));
    scaledHog.totalNumberOfFeatures = newWidth*newHeight*31;
    scaledHog.dimensionOfHogFeatures = (int *)malloc(3*sizeof(int));
    scaledHog.dimensionOfHogFeatures[0] = newHeight;
    scaledHog.dimensionOfHogFeatures[1] = newWidth;
    scaledHog.dimensionOfHogFeatures[2] = 31;

    double xscale = newWidth*1.0/width;
    double yscale = newHeight*1.0/height;
    double yend = 0.0;
    
    for(int feat = 0; feat<31;feat++)
        for (int f = 0; f < newHeight; f++) // y on output
        {
            double ystart = yend;
            yend = (f + 1) / yscale;
            if (yend >= height) yend = height - 0.000001;
            double xend = 0.0;
            for (int g = 0; g < newWidth; g++) // x on output
            {
                double xstart = xend;
                xend = (g + 1) / xscale;
                if (xend >= width) xend = width - 0.000001;
                double sum = 0.0;
                int num = 0;
                for (int y = (int)ystart; y <= (int)yend; ++y)
                {
                    double yportion = 1.0;
                    if (y == (int)ystart) yportion -= ystart - y;
                    if (y == (int)yend) yportion -= y+1 - yend;
                    for (int x = (int)xstart; x <= (int)xend; ++x)
                    {
                        double xportion = 1.0;
                        if (x == (int)xstart) xportion -= xstart - x;
                        if (x == (int)xend) xportion -= x+1 - xend;
                        sum += originalHog.features[y + x*height + feat*width*height] * yportion * xportion;
                        num++;
                    }
                }
                scaledHog.features[f + g*newHeight + feat*newHeight*newWidth] = sum*1.0*exp(-1.294*scale/numScalesPerOctave)/num;
            }
        }
    
    
    return scaledHog;
    
}


@end
