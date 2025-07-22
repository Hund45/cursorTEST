// Demo audio generator for testing the visualizer
class DemoAudioGenerator {
    constructor(audioContext, analyser) {
        this.audioContext = audioContext;
        this.analyser = analyser;
        this.oscillators = [];
        this.gainNodes = [];
        this.isPlaying = false;
    }
    
    start() {
        if (this.isPlaying) return;
        
        this.isPlaying = true;
        
        // Create multiple oscillators for rich audio
        const frequencies = [220, 330, 440, 550, 660]; // A3, E4, A4, C#5, E5
        
        frequencies.forEach((freq, index) => {
            const oscillator = this.audioContext.createOscillator();
            const gainNode = this.audioContext.createGain();
            
            oscillator.type = index % 2 === 0 ? 'sine' : 'triangle';
            oscillator.frequency.setValueAtTime(freq, this.audioContext.currentTime);
            
            gainNode.gain.setValueAtTime(0.1, this.audioContext.currentTime);
            
            oscillator.connect(gainNode);
            gainNode.connect(this.analyser);
            gainNode.connect(this.audioContext.destination);
            
            // Add some modulation
            const lfo = this.audioContext.createOscillator();
            const lfoGain = this.audioContext.createGain();
            
            lfo.frequency.setValueAtTime(0.5 + index * 0.2, this.audioContext.currentTime);
            lfoGain.gain.setValueAtTime(50, this.audioContext.currentTime);
            
            lfo.connect(lfoGain);
            lfoGain.connect(oscillator.frequency);
            
            oscillator.start();
            lfo.start();
            
            this.oscillators.push(oscillator, lfo);
            this.gainNodes.push(gainNode, lfoGain);
        });
        
        // Add some random frequency sweeps
        this.addRandomSweeps();
    }
    
    addRandomSweeps() {
        setInterval(() => {
            if (!this.isPlaying) return;
            
            const oscillator = this.audioContext.createOscillator();
            const gainNode = this.audioContext.createGain();
            
            oscillator.type = 'sawtooth';
            
            const startFreq = 100 + Math.random() * 800;
            const endFreq = 100 + Math.random() * 800;
            
            oscillator.frequency.setValueAtTime(startFreq, this.audioContext.currentTime);
            oscillator.frequency.exponentialRampToValueAtTime(endFreq, this.audioContext.currentTime + 2);
            
            gainNode.gain.setValueAtTime(0, this.audioContext.currentTime);
            gainNode.gain.linearRampToValueAtTime(0.05, this.audioContext.currentTime + 0.1);
            gainNode.gain.exponentialRampToValueAtTime(0.001, this.audioContext.currentTime + 2);
            
            oscillator.connect(gainNode);
            gainNode.connect(this.analyser);
            gainNode.connect(this.audioContext.destination);
            
            oscillator.start();
            oscillator.stop(this.audioContext.currentTime + 2);
            
        }, 3000 + Math.random() * 5000);
    }
    
    stop() {
        this.isPlaying = false;
        this.oscillators.forEach(osc => {
            try {
                osc.stop();
            } catch (e) {
                // Oscillator might already be stopped
            }
        });
        this.oscillators = [];
        this.gainNodes = [];
    }
}

// Export for use in main app
window.DemoAudioGenerator = DemoAudioGenerator;