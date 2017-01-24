function plot_pyramids( gaussian, laplacian, rows, cols )
% wrapper for tight_subplot
figure(1)

ha = tight_subplot(rows,cols,[.01 .03],[.1 .01],[.01 .01]);
           for ii = 1:9;
               if ii < 6;
                 axes(ha(ii));
                 imagesc(gaussian{ii});

               elseif ii < 10
                 axes(ha(ii));
                 imagesc(laplacian{ii-cols});
                 colormap gray;
               end
           end
end

