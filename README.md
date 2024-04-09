<h1>Median Filtering</h1>
<p>
  Median filtering is a simple, yet effective technique used mainly for image denoising and softening, while still maintaining sharp edges. At its core, it works by replacing a pixel’s intensity with the median of its neighboring pixels. This involves examining the neighbouring pixels surrounding it within a specified sliding window (the kernel) in the image, gathering them into a list, sorting and then choosing the median (middle) value from that list.
</p>
<p>
  Median is preferred over mean due to its handling of extreme values. It is likely that an image that needs to be denoised will have pixels with extreme intensities – in which case finding the mean will result in less accurate values. This is also why images that undergo the median filtering technique will not lose edges and other fine details.
</p>

<h1>What's Here?</h1>
<p>
  Within this repository, you'll find a straightforward implementation of Median Filtering performed via CUDA. Both the input and output images are provided, along with measurements of the algorithm's execution time (which may vary depending on the machine). The image handling relies on the stb_image header library, so ensure you have the necessary header files installed (https://github.com/nothings/stb). While I executed the code on Google Colab, it should execute just as well locally. A CPU implementation (no CUDA) of the program is provided as well.
</p>

<h1>References</h1>
<p>Of course, I can't claim sole authorship for this code. I took references from ChatGPT and other github repositories as well so do check them out:
      <li>https://github.com/jonaylor89/Median-Filter-CUDA </li>
      <li>https://github.com/detel/Median-Filtering-GPU</li>
      <li>https://homepages.inf.ed.ac.uk/rbf/HIPR2/median.htm</li>
</p>
