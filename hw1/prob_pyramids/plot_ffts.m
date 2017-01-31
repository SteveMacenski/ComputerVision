function plot_ffts(gaussian, laplacian, rows, cols)

figure(2)
ha2 = tight_subplot(rows,cols,[.01 .03],[.1 .01],[.01 .01]);
           for ii = 1:9;
               if ii < 6;
                 axes(ha2(ii));
                 colormap jet;
                 imagesc(log(abs(fftshift(fft2(gaussian{ii})))));
               elseif ii < 10
                 axes(ha2(ii));
                 colormap jet;
                 imagesc(log(abs(fftshift(fft2(laplacian{ii-cols})))));
               end
           end
end

