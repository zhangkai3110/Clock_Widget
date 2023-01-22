//
//  ClockWidget.swift
//  ClockWidget
//
//  Created by Quentin Beukelman on 21/01/2023.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        
        for hourOffset in 0 ..< 130 {
            let entryDate = Calendar.current.date(byAdding: .second, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

// MARK: - Entry
struct ClockWidgetEntryView : View {
    
    @State var index = 0
    @State var start: Date = Date()
    
    var now: Date
    var entry: Provider.Entry
    
    var body: some View {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.hour, .minute, .second], from: entry.date)
        //Convert Date to angle
        var minuteAngle:Double = 0
        var hourAngle:Double = 0
        var secondAngle: Double = 0
        
        if let hour =  dateComponents.hour,
           let minute = dateComponents.minute,
           let second = dateComponents.second {
            let radianInOneHour = 2 * Double.pi / 12
            let radianInOneMinute = 2 * Double.pi / 60
            minuteAngle = Double(minute) * radianInOneMinute
            let actualHour = Double(hour) + (Double(minute)/60)
            hourAngle = actualHour * radianInOneHour
            secondAngle = Double(second) * radianInOneMinute
            
        }
        
        return ZStack {
            
            // Setup
            Background()
            Numbers()

            // Hour hand
            Hand(offSet: 40)
                .fill()
                .foregroundColor(.black)
                .frame(width: 2, alignment: .center)
                .rotationEffect(.radians(hourAngle))
            HandInsetHour(offSet: 10)
                .fill()
                .foregroundColor(.black)
                .frame(width: 5, alignment: .center)
                .rotationEffect(.radians(hourAngle))
                .shadow(radius: 4)

            //Minute hand
            Hand(offSet: 10)
                .fill()
                .foregroundColor(.black)
                .frame(width: 2, alignment: .center)
                .rotationEffect(.radians(minuteAngle))
            HandInsetMinute(offSet: 10)
                .fill()
                .foregroundColor(.black)
                .frame(width: 4, alignment: .center)
                .rotationEffect(.radians(minuteAngle))
                .shadow(radius: 4)

            //Second hand
            Hand(offSet: 5)
                .fill()
                .foregroundColor(.red)
                .frame(width: 1, alignment: .center)
                .rotationEffect(.radians(secondAngle))
                .shadow(radius: 4)
            Hand(offSet: 60)
                .fill()
                .foregroundColor(.red)
                .frame(width: 1, alignment: .center)
                .rotationEffect(.radians(secondAngle-Double.pi))
                .shadow(radius: 4)
            
            Circles()
            
        }
        .frame(width: 155, height: 155, alignment: .center)
        .onAppear(perform: startFunc)
        .onChange(of: now) { _ in
            index += 1
        WidgetCenter.shared.reloadAllTimelines()
        }
    }
    func startFunc() {
        Timer.scheduledTimer(withTimeInterval: 1 /*3*/, repeats: true) { _ in
            self.start = Date()
            // Code here
        }
    }
}

// MARK: WidgetConfiguration
struct ClockWidget: Widget {
    let kind: String = "ClockWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            TimelineView(.periodic(from: .now, by: 1.0)) { timeline in
                ClockWidgetEntryView(now: timeline.date, entry: entry)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1)))
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

// MARK: - Background
struct Background: View {
    var body: some View {
        ZStack {
            Circle()
                .fill()
                .foregroundColor(Color(UIColor(red: 60/255, green: 60/255, blue: 100/255, alpha: 1)))
                .frame(width: 158, height: 158, alignment: .center)
            Arc()
                .fill(.white)
                .padding(2)
            Ticks()
            RectangleView()
            Circle()
                .fill()
                .foregroundColor(.black)
                .frame(width: 10, height: 10, alignment: .center)
            
        }
    }
}

// MARK: - RectangleView
struct RectangleView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor(red: 250/255, green: 250/255, blue: 255/255, alpha: 1)))
                .frame(width: 26, height: 26)
                .position(x: 53, y: 80)
//                .shadow(color: Color.black.opacity(0.08), radius: 2)

//            RoundedRectangle(cornerRadius: 8)
//                .strokeBorder(Color(UIColor(red: 240/255, green: 240/255, blue: 255/255, alpha: 1)), lineWidth: 0.5)
//                .frame(width: 26, height: 26)
//                .position(x: 53, y: 80)
        }
       
        Text("-6")
            .position(x: 53, y: 80)
            .font(
                .custom(
                "Helvetica Neue",
                fixedSize: 16)
                .weight(.regular)

            )
            .foregroundColor(Color(UIColor(red: 40/255, green: 40/255, blue: 60/255, alpha: 1)))
    }
}

// MARK: - Circles
struct Circles: View {
    var body: some View {
        ZStack {
            Circle()
                .fill()
                .foregroundColor(.red)
                .frame(width: 7, height: 7, alignment: .center)
            Circle()
                .fill()
                .foregroundColor(.white)
                .frame(width: 3, height: 3, alignment: .center)
        }
    }
}


// MARK: - Arc
struct Arc: Shape {
    
    var startAngle: Angle = .radians(0)
    var endAngle: Angle = .radians(Double.pi * 2)
    var clockWise: Bool = true
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width/2, rect.height/2)
        
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockWise)
        return path
    }
}

// MARK: - Tick
struct Tick: Shape {
    var isLong: Bool = false
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY + 6))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY + 7 + (isLong ? 4 : 0)))
        return path
    }
}

// MARK: Ticks
struct Ticks: View {
    var body: some View {
        ZStack {
            ForEach(0..<60) { position in
                Tick(isLong: position % 5 == 0)
                    .stroke(lineWidth: 1.5)
                    .rotationEffect(.radians(Double.pi*2 / 60 * Double(position)))

            }
        }
        .foregroundColor(Color(UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1)))
    }
}


// MARK: - Number
struct Number: View {
    var hour: Int
    var body: some View {
        VStack {
            Text("\(hour)")
                .font(
                    .custom(
                    "Futura",
                    fixedSize: 16)
                    .weight(.medium)

                )
                .foregroundColor(.black)
                .rotationEffect(.radians(-(Double.pi*2 / 12 * Double(hour))))
            Spacer()
        }
        .padding(14)
        .rotationEffect(.radians( (Double.pi*2 / 12 * Double(hour))))
    }
}

// MARK: Numbers
struct Numbers: View {
    var body: some View {
        ZStack {
            ForEach(1..<13) { hour in
                Number(hour: hour)
            }
        }
    }
}

// MARK: - Hand
struct Hand: Shape {
    var offSet: CGFloat = 0
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRoundedRect(in: CGRect(origin: CGPoint(
            x: rect.origin.x,
            y: rect.origin.y + offSet),
                                       size: CGSize(
                                        width: rect.width,
                                        height: rect.height/2 - offSet)), cornerSize: CGSize(
                                            width: rect.width/2,
                                            height: rect.width/2))
        return path
    }
}

// MARK: HandInsetHour
struct HandInsetHour: Shape {
    var offSet: CGFloat = 0
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRoundedRect(in: CGRect(origin: CGPoint(
            x: rect.origin.x,
            y: rect.origin.y + (offSet*4)),
                                       size: CGSize(
                                        width: rect.width,
                                        height: rect.height/2 - (offSet*5))), cornerSize: CGSize(
                                            width: rect.width/2,
                                            height: rect.width/2))
        return path
    }
}

// MARK: HandInsetMinute
struct HandInsetMinute: Shape {
    var offSet: CGFloat = 0
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRoundedRect(in: CGRect(origin: CGPoint(
            x: rect.origin.x,
            y: rect.origin.y + (offSet)),
                                       size: CGSize(
                                        width: rect.width,
                                        height: rect.height/2 - (offSet*2))), cornerSize: CGSize(
                                            width: rect.width/2,
                                            height: rect.width/2))
        return path
    }
}

struct ClockWidget_Previews: PreviewProvider {
    static var previews: some View {
        ClockWidgetEntryView(now: Date(), entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
