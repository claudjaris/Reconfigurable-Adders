#!/bin/bash
# this script generates sub-folders with different adder designs
# testbench input files generated with bash script "rand_gen"
# implemented and tested with tcl script "implementation_and_test"
# approximation statistics generated with bash script "approx_error_stats"
#
# change top name and bit width accordingly
top=top
width=4

par=6

function explore {
  while [ $(jobs -p|wc -l) -ge "$par" ]; do sleep 10; done
  # create directory
  dir="${width}_${design}_${array}_${ri}${rj}${rk}${rl}_${pi}${pj}${pk}${pl}.${device}"
  if [ -e "$dir" ]; then
    echo 1>&2 "Skipping completed configuration ($dir)"
  else
    echo 1>&2 "Starting exploration of configuration ($dir)"
    mkdir $dir
    # copy all necessary files into subfolder
    cp -p -R *.vhd *.txt kintex_freq.tcl approx_error_stats.sh $dir
    cd $dir
      # change top and testbench file generics accordingly
      sed -i -e"s/^\( *constant N *: *positive *:= *\)\([0-9]*\);/\1 $width;/" $top\_tb.vhd
      sed -i -e"s/^\( *N *: *positive *:= *\)\([0-9]*\);/\1 $width;/" $top.vhd
      sed -i -e"s/^\( *T *: *natural *:= *\)\([0-9]*\)/\1 $design/" $top.vhd
      if [ $design != 11 ]; then
        Rvect="(2,3,3)"
        Pvect="(0,1,3)"
      else
      sed -i -e"s/^\( *R_vect *: *my_array_t *:= *\)\(([0-9,]*)\)/\1 $Rvect/" $top.vhd
      sed -i -e"s/^\( *P_vect *: *my_array_t *:= *\)\(([0-9,]*)\)/\1 $Pvect/" $top.vhd
      fi
      # start TCL script for implementation and write out the results
      /afs/pd.inf.tu-dresden.de/sw/Vivado-17.1/Vivado/2017.1/bin/vivado -mode batch -source kintex_freq.tcl
      # start approximation script for statistics and diagrams
      bash approx_error_stats.sh "$design" "$width"
    cd ..
  fi
}

# go over each bit width and design
for device in Kintex7; do
  while [[ $width -lt 9 ]]; do
    # for simulation purposes get random ordered input data
    bash rand_gen.sh "$width"
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
        # QuAd adder array size
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
