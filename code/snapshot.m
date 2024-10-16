clear all
close all
clc

%%% -- ACQUISIZIONE IMMAGINE

chiusi = imread('segnaletica/chiusi.jpg');
aperti = imread('segnaletica/aperti.jpg');

threshold = 20;

det_viso = vision.CascadeObjectDetector(); 
det_occhi = vision.CascadeObjectDetector('EyePairBig');

img = imread("occhi_aperti/prova2.jpg");
box_viso = step(det_viso, img);
colonna_black_pixel = 0;

%%% VERIFICO CHE IL BOX SIA PIENO --> VISO TROVATO --> PROCEDO NEL TROVARE
%%% IL RETTANGOLO PIU' GRANDE

if ~ isempty(box_viso)
    biggest_box_viso = 1;
    for i = 1:rank(box_viso)
        if box_viso(i,3) > box_viso(biggest_box_viso,3)
            biggest_box_viso = i;
        end
    end
    %%% MOSTRO IL VISO TROVATO E CREO UN RETTANGOLO ATTORNO AL VISO

    subplot(2,3,1), imshow(img),title("Immagine originale"); hold on;
    for i=1:size(box_viso,1) %nel caso in cui ci siano più box lo faccio per tutti
        rectangle('position', box_viso(biggest_box_viso, :), 'lineWidth', 2, 'edgeColor', 'g');
    end

    %%% RITAGLIO IL VISO

    viso_ritagliato = imcrop(img, box_viso(biggest_box_viso,:)); % biggest box sarebbe la riga/seleziono la più grande
    box_occhi = step(det_occhi, viso_ritagliato);
    
    %%% VERIFICO CHE IL BOX SIA PIENO --> OCCHI TROVATI--> PROCEDO NEL TROVARE
    %%% IL RETTANGOLO PIU' GRANDE
    
    if ~ isempty(box_occhi)
        
        %%% MOSTRO IL VISO TROVATO E CREO UN RETTANGOLO ATTORNO AL VISO

        subplot(2,3,2), imshow(viso_ritagliato),title("Immagine ritagliata"); hold on;
        for i=1:size(box_occhi, 1) 
            rectangle('position', box_occhi(1, :), 'lineWidth', 2, 'edgeColor', 'g');
        end

        %%% RITAGLIO GLI OCCHI E MODIFICO L'IMMAGINE
        
        occhi_ritagliati = imcrop(viso_ritagliato, box_occhi(1,:));

        occhi_ritagliati_gray1 = rgb2gray(occhi_ritagliati);
        occhi_ritagliati_gray = imadjust(occhi_ritagliati_gray1);
        immagine_finale = imsharpen(occhi_ritagliati_gray,'Radius',3,'Amount',1);
        
        
        %%% PROCEDIAMO NEL CALCOLARE IL NUMERO DI OCCHI RISCONTRATI E
        %%% DISEGNARE UN CERCHIO VERDI INTORNO ALLA PUPILLA

        r = box_occhi(1,4)/4;
        [centers, radii] = imfindcircles(immagine_finale, [floor(r-r/4) floor(r+r/2)], 'ObjectPolarity', 'dark', 'Sensitivity', 0.93); 
        subplot(2,3,4), imshow(immagine_finale), title("Immagine in scala di grigi"); hold on; % Mando in output l'occhio ritagliato
        viscircles(centers, radii, 'EdgeColor', 'g');
        numero_occhi = size(centers,1);


        %%% TRASFORMO L'IMMAGINE IN BIANCO E NERO PER VERIFICARE IL
        %%% RAPPORTO DI PIXEL NERI E BIANCHI
        

        immagine_binaria = im2bw(immagine_finale,threshold/100);

        se = strel('disk',1);
        immagine_erosa = imerode(immagine_binaria,se);
       
        primo_filtraggio = medfilt2(immagine_erosa, [3 3]);
        immagine_filtrata = medfilt2(primo_filtraggio,[3 3]);

        black_pixel = 0;
        white_pixel = 0;
                for g = 1:size(immagine_filtrata,1)
                    for d = 1:size(immagine_filtrata,2)
                        if immagine_filtrata(g,d) == 0
                            black_pixel = black_pixel +1;
                        else
                            white_pixel = white_pixel + 1;
                        end
                    end
                end

         rapporto = black_pixel/(white_pixel);
         subplot(2,3,5),imshow(immagine_filtrata),title("Immagine binaria");
         xlabel("Rapporto pixel neri su bianchi: " + rapporto)

                
         %%% CONTIAMO IL NUMERO DI PIXEL ALL'INTERNO DI CIASCUNA COLONNA
         
         for k = 1:size(immagine_filtrata,2)
             black_pixel_2 = 0;
             white_pixel_2 = 0;
             for h = 1:size(immagine_filtrata,1)
                 if immagine_filtrata(h,k) == 0
                     black_pixel_2 = black_pixel_2 +1;
                 else
                     white_pixel_2 = white_pixel_2 +1;
                 end
             end

             if black_pixel_2 > threshold
                 colonna_black_pixel = colonna_black_pixel + 1;
             end

         end

        
        if numero_occhi == 0
            disp('Chiusi')
            subplot(2,3,6),imshow(chiusi),title("Stato degli occhi")
            %colonna_black_pixel = 0;
        
        elseif numero_occhi >= 1

            if colonna_black_pixel > threshold + 10
                disp('Aperti');
                subplot(2,3,6),imshow(aperti),title("Stato degli occhi") 
            end

        end

    end

else

    disp("Volto non rilevato")
    figure
    imshow('segnaletica/volto_non_riconosciuto.jpg'); 
end


