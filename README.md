# Drowsiness-Detection-System

This project is based on a system capable of detecting whether an individual's eyes are open or closed, and consequently, signaling any drowsiness states. 
The article considered for the project development is by M. Kahlon and S. Ganesan, titled "Driver Drowsiness Detection System Based on Binary Eyes Image Data," published in 2018.

It presents a study on the implementation of an algorithm capable of detecting driver weariness based on the state of their eyes through iris detection. If the person’s eyes remain closed for a predetermined period, the system fails to detect the iris and alerts the driver, indicating drowsiness.

The approach used in the article employs the Viola-Jones algorithm to detect facial features like the face, eyes, mouth, etc.

After image acquisition, the cropped eye portion is first converted to grayscale and then into a binary image; it is subsequently processed to reduce noise.

Here’s how you can describe the structure of the code in the **README** file in English:


# Code Structure of the Repository

The repository is organized into the following main folders and files:

### `code` folder
- Contains the main code to test the algorithm's functionality for detecting whether eyes are open or closed.
- The **`snapshot.m`** file runs the algorithm on static images of individuals, allowing analysis of whether their eyes are open or closed.
- The **`real_time.m`** file applies the algorithm on real-time video captured via a webcam, enabling live detection.

### `images` folder
- Contains three subfolders with images of individuals to analyze for detecting if their eyes are open or closed. These images are used by the `snapshot.m` file to test the algorithm.

### `segnaletica` folder
- Contains the notification pop-ups used by the program to signal the eye status (open or closed). These pop-ups provide visual feedback to the user during the real-time execution of the algorithm.


This layout clearly explains the repository structure and the role of each component.

## Algorithmic Basis

The detection of drowsiness is based on three main checks:

1. Ratio of black to white pixels
2. Number of pixels (within a column) exceeding a certain threshold
3. Eye shape

In the first case, black and white pixels within the binary image are counted, and the black-to-white ratio is calculated. The result is then compared for both open and closed eyes: if the eyes are open, the ratio will be higher than when the eyes are closed.

The second check detects the number of black pixels within a column of the binary image and the number of columns identified. If these values exceed a previously defined threshold, the eye is considered open.

The final check involves detecting the column containing the maximum number of black pixels. If the preceding and following columns have fewer black pixels than the one in question, the eye is detected as open.

If at least two of the three conditions are met, the eye detection is successful, and its state is identified as "open." Otherwise, the system signals drowsiness.


## Project Architecture

To explain the process clearly, it is necessary to outline the different phases in their chronological order.

These phases are listed below:

- Image acquisition
- Face and eye detection
- Image conversion and processing
- Metric calculations for detection
- Final results

The flowchart below provides a general overview of how our algorithm functions.

<img width="600" alt="Senza titolo" src="https://github.com/user-attachments/assets/d760fc7d-b237-4788-bf63-542a73b7b0f1">

**1 - Image Acquisition**

The project in question is capable of processing both real-time images acquired via the computer’s webcam and previously captured images.

Focusing on real-time video acquisition, the first step was to create a webcam object for capturing frames from the webcam and initialize two detectors. The first, "det_viso," is for face detection, while the second, "det_occhi," is for eye detection.  
The cam object obtains a continuous series of frames that need to be processed one by one. Therefore, using the “snapshot” function, a snapshot of the video is taken to acquire an image, which is then flipped horizontally using the "flip" function.  
Finally, the images "chiusi" (closed) and "aperti" (open) are read as input using the "imread" command, which will be useful later for determining the state of the eyes.

**2 - Face and Eye Detection**

The next step involves detecting the face based on the acquired images. For this purpose, the variable "box_viso" is initialized, which detects the face. This variable represents a vector where the first two elements define the top-left coordinates of the box, the third specifies the width of the box, and the fourth indicates its height. Once this is done, an initial check is performed. If no face is detected, an error message is returned, indicating that the subject is out of frame.

Otherwise, to avoid incorrect detections, the system proceeds to identify the largest box within the image, assuming that the subject to be examined is always in the foreground.

Once the face is detected, the variable "viso_ritagliato" is initialized, where the portion of the image of interest is cropped, eliminating non-essential components based on the coordinates contained within the "box_viso" variable.

Then, the same steps used for face detection are repeated, this time using the eye detector on the previously cropped image. The final image is saved in the "occhi_ritagliati" variable.

**3 - Image Conversion and Processing**

**3.1 - RGB to Grayscales**

The next phase involves converting the cropped image from "RGB" to "grayscale" using the "rgb2gray" function. This command converts RGB values into grayscale values, removing hue and saturation information while retaining the brightness of the image.

Next, the contrast was adjusted using the "imadjust" function, and the grayscale sharpness was enhanced using the "imsharpen" command, with a radius set to three, which controls the size of the pixel region of interest.  
Sharpness, in essence, represents the contrast between different colors. For example, a rapid transition from black to white makes the image appear sharper, while a gradual transition from black to gray makes the white look more blurred. Sharpness increases contrast along edges where different colors meet, making the eyes within the image more focused.

For iris detection, the "imfindcircle" function was crucial. It outputs a two-column matrix containing the coordinates of the centers of circles in the image. The input parameters include the image to which the function will be applied, the "radiusRange," which specifies the range of radii for the circular objects to detect (given as a two-element vector of positive integers), and finally, a sensitivity factor expressed on a scale from 0 to 1. Increasing sensitivity allows the detection of more circular objects, including hidden or partially obscured circles, but values that are too high increase the risk of false detections.

It’s important to note that the initial radius was estimated based on the size of the "box_occhi." Once calculated, a tolerance was introduced to determine the minimum and maximum radius, and the "viscircles" function was used to draw two circular shapes corresponding to the iris of the eyes.

Finally, to check the number of circles detected, a control is performed on the number of rows in the "center" matrix, as a row count of zero implies that no circles were detected. This value will be crucial in later steps to determine whether a person’s eyes are open or closed.

**3.2 - Grayscale to Black and White**

The final processing phase involves converting the image to black and white. A binary image is saved in a matrix containing only two values: zero for black pixels and one for white pixels.

This transformation was achieved using the "im2bw" function, which takes the source image and a threshold as inputs. Matlab automatically sets this threshold to 0.5.  
The threshold value is critical because it is directly proportional to noise. If too low, some components of the image may be lost; if too high, too much noise may be introduced into the image. Through multiple tests, the threshold was set to 0.20 to achieve the desired result.

After this, the "se" object is initialized, saving an essential element structure for the erosion operation. The basic idea is to probe an image with a simple predefined shape, drawing conclusions about how this shape fits or misses the shapes in the image. This simple "probe" is called a structural element and is itself a binary image, where pixels equal to one are included in the morphological calculation, while pixels equal to zero are not.

By applying erosion to a binary image, the contours of the "foreground pixel" regions (typically the white pixels) are eroded. To calculate the erosion of a binary image "A" using a structuring element, we overlay this element on each pixel of the image. If all pixels under the structuring element are foreground pixels, the input pixel retains its value; otherwise, it takes the value of the background.

**Original Image vs. Eroded Image**

The final step involves noise removal using the "medfilt2" command twice, where each output pixel contains the median value within the neighborhood specified by the matrix [m n] around the corresponding pixel in the eroded image.  
The median filter applies non-linear operations and reduces noise within the image.

**4 - Metric Calculations for Detection**

Before determining whether a person’s eyes are open or closed, an additional check is performed to count the number of black pixels within each column of the binary image. Three variables are initialized to zero:

- colonna_black_pixel
- black_pixel
- white_pixel

A double loop is performed, the outer loop referring to the columns, the inner loop to the rows of the "filtered_image" matrix. If the i-th element of the matrix equals 0, the black pixel counter is incremented; otherwise, the white pixel counter is.  
If the number of pixels in the column exceeds a certain threshold—20 for images processed by the algorithm and 15 for real-time video—the column counter is incremented. The correct threshold was determined through extensive experiments on both input images and those created via the webcam, which captures a lower-quality image. Therefore, the threshold was reduced by five units for real-time detection. Once the entire matrix is examined, the "colonna_black_pixel" variable will contain the number of columns where the black pixel count exceeds the threshold.

Finally, a similar operation is performed to calculate the ratio between black and white pixels to justify the detection of a drowsiness state.

Based on these operations, the eye state is verified:

- If the "numero_occhi" variable is zero (recalling that zero means no circle was detected), a message is displayed on the screen indicating that the person’s eyes are closed, and the "contatore_occhi_chiusi" counter is incremented.
- If the variable value exceeds five, a drowsiness state is detected, and a warning message is sent as output.
- If "numero_occhi" is greater than one, an additional check is performed to avoid false positives.
- If the number of columns calculated earlier exceeds the threshold plus a certain tolerance, a message is displayed indicating that the eyes are open, and the "contatore_occhi_chiusi" variable is reset to zero.

The ratio calculation justifies the algorithm’s decision: if the eyes are open, the black-to-white pixel ratio will be higher than when the eyes are closed. Additionally, the fact that the image was cropped does not affect the final ratio, as the image size and ratio are directly proportional.
