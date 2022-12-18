package main
import (
	"io"
	"os"
	mp4 "github.com/yapingcat/gomedia/go-mp4"
)

func main() {
	f, err := os.Open(os.Args[1])
	if err != nil {
		return
	}
	defer f.Close()

	demuxer := mp4.CreateMp4Demuxer(f)
	if _, err := demuxer.ReadHead(); err != nil && err != io.EOF {
		return
	} 
	demuxer.GetMp4Info()
	for {
		_, err := demuxer.ReadPacket()
		if err != nil {
			break
		}
	}
	return
}
