# Optical-Character-Recognition

Optical Character Recognition (OCR) is process of extracting characters from image or scanned document into machine encoded text (or simply 
text that can be manipulated). Application is made for iOS platform (both iPhone and iPad, OS 8.0 and above). Application can convert any type of images (color, greyscale,...)
, however only typewritten text can be extracted (handwriting is not supported by the application). It is used open source Tesseract framewrok for extraction and recognition,
while other image preprocessing are done by myself. 
Process of extraction consists of multiple complex steps
  - image preprocessings
  - converison of color image into grayscale
  - binarisation (converting image into only black & white shades)
  - feature or blob extraction
  - feature classification and character recognition
  
The steps mentioned above has to be performed in the same order as stated. In the project, for converting color image into greyscale iti is used'luma coding' approach, in binarisation process it is  used algorithm 'Adaptive Threshold by Integral Image'. Furthermore, feature extraction is implemented by 
following 'Two Pass' algorithm, and finally classification and recognition is done by 'neural network'.
When each step (from those above) is finished, new image is shown. So for instance, if step of converting color image into greyscale is performed, main view is updated by setting new greyscale image as main view.
Application consists of two view controllers:
  - first view show steps in processings and as image picker controller (image can be picked from gallery or taken by camera directly from app)
  - second view is triggered when text is extracted and needs to be shown
  <p align="center">
  <img src="https://raw.githubusercontent.com/ModernMantra/Optical-Character-Recognition/master/IMG_1373.jpg" width="350"/>
  </p>
