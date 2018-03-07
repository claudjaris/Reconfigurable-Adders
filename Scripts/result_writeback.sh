#!/bin/bash
# this script writes out all results from all adder variants
#
# change top name and bit width accordingly
top=top
width=4

par=6

function explore {
  while [ $(jobs -p|wc -l) -ge "$par" ]; do sleep 10; done
  # directory names
  dir="${width}_${design}_${array}_${ri}${rj}${rk}${rl}_${pi}${pj}${pk}${pl}.${device}"
  dir_small="${design}_${array}_${ri}${rj}${rk}${rl}_${pi}${pj}${pk}${pl}"
  if [ -e "$dir" ]; then
    echo 1>&2 "Copying RESULT of $dir_small"
    cd $dir
      # copy Error probability and Average relative error and MSE for each result
      cd 'ApproxResult_'$design
        cp ApproxResult_$design.txt AppResult
        sed -i -e "s/Error probability = \([0-9][0-9]*\)\.*\([0-9]\{0,3\}\)[0-9]*%/\1.\2/w APP_RES" -e "s/Average relative error = \([0-9][0-9]*\)\.*\([0-9]\{0,3\}\)[0-9]*/ \1.\2/w APP_RES" -e "s/Mean squared error = \([0-9][0-9]*\)\.*\([0-9]\{0,3\}\)[0-9]*/ \1.\2/w APP_RES" AppResult
        tr '\n' ' ' < APP_RES > APP_TMP
        cp APP_TMP ../APP_TMP
      cd ..
      # get implementation results and approximate results in one file
      cp RESULT RES_TMP
      paste RES_TMP APP_TMP > RESULT_TMP
      sed -i -e "s/\([0-9][0-9]*\)\.\([0-9]\{1,3\}\)[0-9]*  \([0-9][0-9]*\)  \([0-9][0-9]*\)  \([0-9][0-9]*\)\.\([0-9]\{1,3\}\)[0-9]*\t\([0-9][0-9]*\.*[0-9]\{0,3\}\)[0-9]*  \([0-9][0-9]*\.*[0-9]\{0,3\}\)[0-9]*  \([0-9][0-9]*\.*[0-9]\{0,3\}\)[0-9]*/$width,\t\t\t \1.\2,\t \3,\t\t\t \4,\t\t \5.\6,\t \7,\t\t\t\t\t\t\t\t \8,\t\t\t\t\t\t\t\t\t\t \9,\t\t\t $dir_small/" RESULT_TMP
      # copy all results from all designs into one file
      cat RESULT_TMP >> ../RESULT_ALL 
    cd ..
  fi
}

# go over different bit widths and designs
for device in Kintex7; do
  rm RESULT_ALL
  # create file with attribute header
  echo -e "Width,\t Delay,\t LUTs,\t CCs,\t Power,\t\t Error probability,\t Average relative error,\t MSE,\t\t\t Design" >> RESULT_ALL
  # less than maximum bit width
  while [[ $width -lt 9 ]]; do
for design in 0 1 2 3 4 5 6; do
      if [ $design = 0 ]; then
        array=
        ri=
        rj=
        rk=
        rl=
        pi=
        pj=
        pk=
        pl=
        explore
      else
      if [ $design = 1 ]; then
        array=
        ri=
        rj=
        rk=
        rl=
        pi=
        pj=
        pk=
        pl=
        explore
      else
      if [ $design = 2 ]; then
        array=
        ri=
        rj=
        rk=
        rl=
        pi=
        pj=
        pk=
        pl=
        explore
      else
      if [ $design = 3 ]; then
        ri=
        rj=
        rk=
        rl=
        pi=
        pj=
        pk=
        pl=
        explore
      else
      if [ $design = 4 ]; then
        array=
        ri=
        rj=
        rk=
        rl=
        pi=
        pj=
        pk=
        pl=
        explore
      else
      if [ $design = 5 ]; then
        array=
        ri=
        rj=
        rk=
        rl=
        pi=
        pj=
        pk=
        pl=
        explore
      else
      if [ $design = 6 ]; then
        for array in 2 3 4; do
          pi=0
          if [ $array = 2 ]; then
            rk=
            rl=
            pk=
            pl=
            FIN=$width-1
            for ((ri=1;ri<=FIN;ri++)); do
              rj=$(( $width-$ri ))
              Rvect="($ri,$rj)"
              END=$ri-1
              for ((pj=0;pj<=END;pj++)); do
                Pvect="($pi,$pj)"
                explore
              done
            done
          fi
          if [ $array = 3 ]; then
            rl=
            pl=
            FIN=$width-2
            for ((ri=1;ri<=FIN;ri++)); do
              END=$width-$ri-1
              for ((rj=1;rj<=END;rj++)); do
                rk=$(( $width-$ri-$rj ))
                Rvect="($ri,$rj,$rk)"
                KILL=$ri-1
                for ((pj=0;pj<=KILL;pj++)); do
                  STOP=$ri+$rj-2
                  for ((pk=0;pk<=STOP;pk++)); do
                    Pvect="($pi,$pj,$pk)"
                    explore
                  done
                done
              done
            done
          fi
          if [ $array = 4 ]; then
            FIN=$width-3
            for ((ri=1;ri<=FIN;ri++)); do
              END=$width-$ri-2
              for ((rj=1;rj<=END;rj++)); do
                HALT=$width-$ri-$rj-1
                for ((rk=1;rk<=HALT;rk++)); do
                  rl=$(( $width-$ri-$rj-$rk ))
                  Rvect="($ri,$rj,$rk,$rl)"
                  KILL=$ri-1
                  for ((pj=0;pj<=KILL;pj++)); do
                    STOP=$ri+$rj-2
                    for ((pk=0;pk<=STOP;pk++)); do
                      BREAK=$ri+$rj+$rk-3
                      for ((pl=0;pl<=BREAK;pl++)); do
                        Pvect="($pi,$pj,$pk,$pl)"
                        explore
                      done
                    done
                  done
                done
              done
            done
          fi
        done
      fi
      fi
      fi
      fi
      fi
      fi
      fi
      fi
      fi
      fi
      fi
      fi
    done
    # increase bit width by 2
    (( width+=2 ))
  done
done  
wait
