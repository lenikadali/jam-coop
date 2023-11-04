# frozen_string_literal: true

class TranscodeJob < ApplicationJob
  queue_as :default

  def perform(track, format: :mp3v0)
    output_fn = "#{track.original.filename.base}.#{file_extension(format)}"

    Tempfile.create('transcode') do |output|
      track.original.open do |file|
        if track.album.cover.attached?
          track.album.cover.open do |image|
            transcode(file, output, format, metadata_for(track), image)
          end
        else
          transcode(file, output, format, metadata_for(track))
        end
      end
      track.transcodes.where(format:).destroy_all
      transcode = track.transcodes.create(format:)
      transcode.file.attach(io: File.open(output.path), filename: output_fn, content_type: content_type(format))
    end
  end

  private

  def metadata_for(track)
    {
      track_title: track.title,
      album_title: track.album.title,
      artist_name: track.artist.name
    }
  end

  def transcode(input, output, format, metadata, image = nil)
    TranscodeCommand.new(input, output, format, metadata, image).execute
  end

  def content_type(format)
    case format
    when :mp3v0, :mp3128k
      'audio/mpeg'
    when :flac
      'audio/flac'
    else
      raise ArgumentError, "unsupported format: #{format}"
    end
  end

  def file_extension(format)
    case format
    when :mp3v0, :mp3128k
      'mp3'
    when :flac
      'flac'
    else
      raise ArgumentError, "unsupported format: #{format}"
    end
  end
end
