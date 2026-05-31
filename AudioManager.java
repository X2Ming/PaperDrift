// audio playback manager
// written as plain Java because the Processing pde preprocessor can misinterpret Java Sound code
import java.io.File;
import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.Clip;
import javax.sound.sampled.FloatControl;

public class AudioManager {
  // single BGM track
  private final String dataFolderPath;
  private Clip bgmClip;

  public AudioManager(String dataFolderPath) {
    // store the data folder path for later use
    this.dataFolderPath = dataFolderPath;
  }

  public void load() {
    // look for bgm.wav first, then fall back to the first audio file in data folder
    File musicFile = findMusicFile();
    if (musicFile == null) {
      System.out.println("Music file not found in data folder");
      return;
    }

    bgmClip = loadClip(musicFile);
  }

  public void start() {
    // start looping the BGM when gameplay begins
    startLoop(bgmClip, 0.76f);
  }

  public void stop() {
    // stop music when the game ends
    stopClip(bgmClip);
  }

  public void update() {
    setVolume(bgmClip, 0.76f);
  }

  private File findMusicFile() {
    File dataFolder = new File(dataFolderPath);
    if (!dataFolder.exists() || !dataFolder.isDirectory()) {
      return null;
    }

    File preferredWav = new File(dataFolder, "bgm.wav");
    if (preferredWav.exists()) {
      return preferredWav;
    }

    File preferredMp3 = new File(dataFolder, "bgm.mp3");
    if (preferredMp3.exists()) {
      return preferredMp3;
    }

    File[] files = dataFolder.listFiles();
    if (files == null) {
      return null;
    }

    for (int i = 0; i < files.length; i++) {
      String name = files[i].getName().toLowerCase();
      if (name.endsWith(".wav")) {
        return files[i];
      }
    }

    for (int i = 0; i < files.length; i++) {
      String name = files[i].getName().toLowerCase();
      if (name.endsWith(".mp3")) {
        return files[i];
      }
    }

    return null;
  }

  private Clip loadClip(File soundFile) {
    // wav is the most reliable format for Java Sound; mp3 may fail gracefully
    try {
      AudioInputStream stream = AudioSystem.getAudioInputStream(soundFile);
      Clip loadedClip = AudioSystem.getClip();
      loadedClip.open(stream);
      stream.close();
      return loadedClip;
    } catch (Exception e) {
      System.out.println("Could not load music file " + soundFile.getName() + " " + e.getMessage());
      return null;
    }
  }

  private void startLoop(Clip clip, float volume) {
    // loop from the beginning
    if (clip == null) {
      return;
    }

    clip.stop();
    clip.setFramePosition(0);
    setVolume(clip, volume);
    clip.loop(Clip.LOOP_CONTINUOUSLY);
  }

  private void stopClip(Clip clip) {
    // safely stop without crashing on null
    if (clip == null) {
      return;
    }

    clip.stop();
    clip.setFramePosition(0);
  }

  private void setVolume(Clip clip, float amount) {
    // convert 0–1 volume to decibels for Java Sound
    if (clip == null || !clip.isControlSupported(FloatControl.Type.MASTER_GAIN)) {
      return;
    }

    amount = Math.max(0.0f, Math.min(1.0f, amount));
    FloatControl gain = (FloatControl)clip.getControl(FloatControl.Type.MASTER_GAIN);
    if (amount <= 0.001f) {
      gain.setValue(gain.getMinimum());
      return;
    }

    float minGain = Math.max(gain.getMinimum(), -45.0f);
    float maxGain = Math.min(gain.getMaximum(), 0.0f);
    float db = minGain + (maxGain - minGain) * amount;
    gain.setValue(db);
  }
}
