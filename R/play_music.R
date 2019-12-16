library(dplyr)
library(audio)

#' Play a piece of music constructed from vectors of pitch and duration
#'
#' @param notes_pitch Character vector of notes using standard musical note terminology.  Append # or b for sharp of flat semitones.  Default octave is
#' octave 4 on a piano keyboard.  Append octave number for lower or higher octaves.
#' @param notes_duration Numeric vector of corresponding note durations in beats.  Must be same length as notes_pitch.
#' @param tempo Numeric tempo to be played in beats per minute.
#'
#' @return Music played in R console.
#'
#' @examples
#'
#' cminor_arpeggio_notes <- c("C3", "D#3", "G3", "C", "D#", "G", "C5")
#' cminor_arpeggio_duration <- rep(2, 7)
#' play_music(cminor_arpeggio_notes, cminor_arpeggio_notes)
play_music <- function(notes_pitch = NULL, notes_duration = NULL, tempo = 240) {

  # set numeric value of notes

  notes <- c(A = 0, B = 2, C = 3, D = 5, E = 7, F = 8, G = 10)

  # handle octaves, semitones and set note frequency around 440 Mhz

  tune <-
    data_frame(
      pitch = notes_pitch,
      duration = notes_duration
    ) %>%
    dplyr::mutate(
      octave = substring(pitch, nchar(pitch)) %>%
        {
          suppressWarnings(as.numeric(.))
        } %>%
        ifelse(is.na(.), 4, .),
      note = notes[substr(pitch, 1, 1)],
      note = note + grepl("#", pitch) -
        grepl("b", pitch) + octave * 12 +
        12 * (note < 3),
      freq = 2^((note - 60) / 12) * 440
    )

  sample_rate <- 44100

  # sine wave funcrion

  make_sine <- function(freq, duration) {
    wave <- sin(seq(0, duration / tempo * 60, 1 / sample_rate) *
      freq * 2 * pi)
    fade <- seq(0, 1, 50 / sample_rate)
    wave * c(fade, rep(1, length(wave) - 2 * length(fade)), rev(fade))
  }

  # create wave file

  tune_wave <- mapply(make_sine, tune$freq, tune$duration, SIMPLIFY = FALSE) %>%
    do.call("c", .)

  # play wave file

  audio::play(tune_wave)
}