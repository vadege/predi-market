# Copyright 2015 Kjetil Thuen
# Distributed under the GPLv3

margin_left = 10
margin_top = 10
margin_right = 120
margin_bottom = 15
brushAreaSize = 0 #0.2
padding = 20
width = 1000
height = 300

xScale = d3.time.scale()
   .range [margin_left, (width - margin_right)]

xScaleBrush = d3.time.scale()
   .range [margin_left, (width - margin_right)]

yScale = d3.scale.linear()
   .range [(height - margin_bottom - (height * brushAreaSize)), margin_top]

yScaleBrush = d3.scale.linear()
   .range [(height - margin_bottom), margin_top + (height * (1 - brushAreaSize))]


brush = d3.svg.brush()
   .x xScaleBrush
   .on "brush", ->
     refresh @ownerSVGElement


position_label = (d) ->
  expression = "translate(" +
    (width - margin_right) +
    ", " +
    yScale(d.price) + ")"
    # ")rotate(" + (d[d.length - 1].price - 50) * 0.45 + ")"
  expression

highlight_timeline = (timeline) ->
  siblings = timeline.parentNode.childNodes
  for sibling in siblings
    unless sibling is timeline
      d3.select sibling
        .transition()
        .duration 500
        .attr 'opacity', 0.3

unhighlight_timeline = (timeline) ->
  siblings = timeline.parentNode.childNodes
  for sibling in siblings
    d3.select sibling
      .transition()
      .duration 500
      .attr 'opacity', 1

get_tooltip = (data, event) ->
  if data
    moment.locale TAPi18n.getLanguage()
    if data.trade_type is "buy"
      text = TAPi18n.__ "tooltip_price_history_buy", {
          postProcess: 'sprintf'
          sprintf: [data.shares, data.avg_price, Math.abs(data.cost), data.worth]
        }
    else
      text = TAPi18n.__ "tooltip_price_history_sell",{
          postProcess: 'sprintf'
          sprintf: [data.shares, data.avg_price, Math.abs(data.cost), data.worth]
        }
    tooltip = {
      text: text
      date: moment(data.timestamp).format("LLLL")
      x: (event.clientX+10)+"px"
      y: (event.clientY-10)+"px"
    }
    return tooltip
  return null

refresh = (svgnode, data) ->
  flattimestamps = _.map _.flatten(data), (datum) -> new Date(datum.timestamp)
  flatprices = _.map _.flatten(data), (datum) -> datum.price
  minprice = d3.min flatprices
  maxprice = d3.max flatprices
  diff = maxprice - minprice
  if diff is 0
    diff = 100
  minprice = minprice - (diff * 0.05)
  maxprice = maxprice + (diff * 0.05)

  xScaleBrush.domain d3.extent(flattimestamps)
  yScaleBrush.domain [minprice, maxprice]

  xScale.domain(if brush.empty() then xScaleBrush.domain() else d3.extent(flattimestamps))
  yScale.domain [minprice, maxprice]

  linechart = d3.svg.line()
    .x (d) ->
      xScale new Date(d.timestamp)
    .y (d) ->
      yScale d.price
    .interpolate "linear"


  brushLinechart = d3.svg.line()
    .x (d) ->
      xScaleBrush new Date(d.timestamp)
    .y (d) ->
      yScaleBrush d.price
    .interpolate "linear"

  xAxis = d3.svg.axis()
     .scale xScale
     .ticks 5, 0
     .tickSize -height + margin_top + margin_bottom
     .tickSubdivide true

  yAxis = d3.svg.axis()
     .scale yScale
     .ticks 6
     .orient "right"

  xAxisBrush = d3.svg.axis()
     .scale xScaleBrush
     .tickSize -(height * brushAreaSize) + margin_top + margin_bottom
     .ticks 5, 0

  svg = d3.select(svgnode).select "svg"

  if brush.empty()
    transdur = 250
  else
    transdur = 1

  # Update Axis
  svg.select(".x.axis").call xAxis
  svg.select(".y.axis").call yAxis
  svg.select(".brush.x.axis").call xAxisBrush

  if data?
    # console.log data.tooltip
    tooltip = d3.select(svgnode).select("div.trade-tooltip").selectAll "div"
      .data data.tooltip
      .text (d) ->
        return d.text
      .style "position", "fixed"
      .style "top", (d) -> d.y
      .style "left", (d) -> d.x

    tooltip.append "div"
      .classed "date", true
      .text (d) -> d.date

    tooltip.exit()
      .remove()

    tip_enter = tooltip.enter()
      .append "div"
      .text (d) -> d.text
      .style "top", (d) -> d.y
      .style "left", (d) -> d.x

    tip_enter.append "div"
      .classed "date", true
      .text (d) -> d.date

    timeline = svg.select("g.timelines").selectAll "g.timeline"
      .data data.chart

    circles = svg.select("g.circles").selectAll "g.circle"
      .data data.chart

    # Enter timeline
    t_enter = timeline.enter()
      .append "g"
      .attr 'class','timeline'
      .attr 'opacity', 1


    # Enter timeline for in_progress preview line
    t_enter.insert "path"
      .classed 'dash-line', true
      .attr "fill", "none"
      .attr 'stroke-dasharray', '5,5'
      .attr "stroke-width", 2
      .style "stroke", (d) -> d[0].color


    # Enter selector insert path
    t_enter.insert "path"
      .classed 'line', true
      .attr "fill", "none"
      .attr "stroke-width", 2
      .style "stroke", (d) -> d[0].color

    # Enter selector add legend group
    t_enter.append "g"
      .classed "legend", true
      .attr "transform", (d, i) -> "translate(" + (margin_bottom + padding) + ", " + (margin_top + padding + (i * 40)) + ")"
      .on 'mouseover', (d) ->
        d3.selectAll('g.circle').each (e) ->
          if e[0].color != d[0].color
            d3.select(@).transition().duration(500).attr 'opacity', 0.3
        d3.selectAll('g.timeline').each (e) ->
          if e[0].color != d[0].color
            d3.select(@).transition().duration(500).attr 'opacity', 0.3
      .on 'mouseout', (d) ->
        d3.selectAll('g.circle').transition().duration(500).attr 'opacity', 1
        d3.selectAll('g.timeline').transition().duration(500).attr 'opacity', 1
      .insert 'text'
      .attr "fill", (d) -> d[0].color
      .text (d) -> "⬤ " + d[0].name
      .attr "font-size", "25px"

    # Enter selector add label group
    label = t_enter
      .append "g"
      .classed 'label', true
      .attr "opacity", -> if brush.empty() then 1 else 0
      .attr "transform", (d) -> position_label d[d.length - 1]
      .on 'mouseover', (d) ->
        d3.selectAll('g.circle').each (e) ->
          if e[0].color != d[0].color
            d3.select(@).transition().duration(500).attr 'opacity', 0.3
        d3.selectAll('g.timeline').each (e) ->
          if e[0].color != d[0].color
            d3.select(@).transition().duration(500).attr 'opacity', 0.3
      .on 'mouseout', (d) ->
        d3.selectAll('g.circle').transition().duration(500).attr 'opacity', 1
        d3.selectAll('g.timeline').transition().duration(500).attr 'opacity', 1

    # Label insert rectangel
    label.insert "rect"
      .attr "x", "10px"
      .attr "y", "-17px"
      .attr "width", "100px"
      .attr "height", "35px"
      .style "fill", (d) -> d[0].color

    # Label insert text element
    label.insert "text"
      .attr "x", "20px"
      .attr "dy", "8px"
      .style "fill", "white"
      .attr "font-size", "25px"

    # Enter circles group
    circles.enter()
      .append "g"
      .attr 'class','circle'
      .attr 'opacity', 1

    show_tooltip = (data, point) ->
      d3.selectAll('g.circle').each (e) ->
        if e[0].color != point.color
          d3.select(@).transition().duration(500).attr 'opacity', 0.3
      d3.selectAll('g.timeline').each (e) ->
        if e[0].color != point.color
          d3.select(@).transition().duration(500).attr 'opacity', 0.3
      d3.select(@).attr 'r',10
      tooltip = get_tooltip point, d3.event
      new_data = {
        chart: data.chart
        tooltip: [tooltip]
      }

      refresh svgnode, new_data

    hide_tooltip = (data, point) ->
      d3.selectAll('g.circle').transition().duration(500).attr 'opacity', 1
      d3.selectAll('g.timeline').transition().duration(500).attr 'opacity', 1
      d3.select(@).attr 'r', 5
      new_data = {
        chart: data.chart
        tooltip: []
      }

      refresh svgnode, new_data

    # Enter and update circles
    # Databind circle
    circle = circles.selectAll("circle")
        .data (timeline) ->
          _.filter timeline, (d) -> d.current_user and d.primary
        .on 'mouseover', _.partial show_tooltip, data
        .on 'mouseout', _.partial hide_tooltip, data

    # Enter each circle
    circle.enter()
      .append "circle"
      .attr "r", 0
      .on 'mouseover', _.partial show_tooltip, data
      .on 'mouseout', _.partial hide_tooltip, data

    # Enter and update circle
    circle.transition()
      .duration transdur
      .attr "r", 5
      #.attr "fill", (d) -> d.color
      .attr "fill", (d) ->
        if d.trade_type is "buy" then "#3b5999" else "#d9534f"
      .attr "visibility", (d) ->
        if d.primary and d.current_user then "visible" else "hidden"
      .attr "cy", (d) -> yScale d.price
      .attr "cx", (d) -> xScale(new Date d.timestamp)

    # Exit circle, Shoud not happend in real data
    circle.exit().remove()

    # Enter and update timeline
    # Update all path, legend, and label elements and groups
    # Ugly hack to select data that is in the in_progress path
    # TODO FIX
    timeline.each (d) ->
      s = d3.select(@)
      s.select 'path.line'
        .transition()
        .attr "d", (d) ->
          linechart _.filter(d, (x) -> !x.in_progress)
      s.select 'path.dash-line'
        .transition()
        .attr "d", (d) ->
          linechart _.filter d, (x,i) ->
            i+2 == d.length || x.in_progress
      s.select 'g.legend text'
        .text (d) -> "⬤ " + d[0].name
      s.select 'g.label'
        .attr "transform", (d) -> position_label d[d.length - 1]
        .attr 'y', (d) ->  yScale(d[d.length - 1].price) # Save position in y attrib, a hack
      s.select 'g.label text'
        .text (d) -> d3.round(d[d.length - 1].price, 2) + "%"


  # constraint relax on labels
    alpha = 2
    spacing = 36
    relaxLabels = () ->
      labels = d3.selectAll 'g.label'
      again = false
      labels.each (x,i1) ->
        a = d3.select @
        labels.each (x,i2) ->
          b = d3.select @
          if i1 == i2  # Do not compre agains one self
            return
          a_y = (Number)  a.attr 'y'
          b_y = (Number)  b.attr 'y'
          dy = a_y - b_y
          if Math.abs(dy) < spacing
            again = true
            sign = dy >= 0 ? 1 : -1
            a_y = a_y + sign*alpha
            b_y = b_y - sign*alpha
            a.attr 'y', a_y
            b.attr 'y', b_y
            a.attr "transform", (d) -> "translate(" +(width - margin_right) + ", " + a_y + ")"
            b.attr "transform", (d) -> "translate(" +(width - margin_right) + ", " + b_y + ")"
      if again == true
        setTimeout(relaxLabels,20)

    # Run the relax function on pabels
    relaxLabels()

###

    # Enters
    timelines_selector = svg.selectAll "g.timelines"
      .selectAll "g.timeline"
    timelines = timelines_selector.data data

    timeline_group = timelines.enter()
      .append "svg:g"
      .attr "class", (d) -> "timeline " + d[0].contract_id
      .attr 'opacity', 1

    timeline_group.selectAll "text.legend"
      .append "svg:g"
      .classed "legend", true
      .attr "fill", (d) -> d[0].color
      .text (d) -> "⬤ " + d[0].name
      .attr "font-size", "25px"
      .attr "transform", (d, i) -> "translate(" + (margin_bottom + padding) + ", " + (margin_top + padding + (i * 40)) + ")"
      .on 'mouseover', -> highlight_timeline(@parentNode)
      .on 'mouseout', -> unhighlight_timeline(@parentNode)

    timeline_group.selectAll "g.label"
      .append "svg:g"
      .classed 'label', true
      .attr "opacity", -> if brush.empty() then 1 else 0
      .attr "transform", (d) -> position_label d[d.length - 1]

    timeline_group.selectAll "g.label rect"
      .append "svg:rect"
      .attr "x", "10px"
      .attr "y", "-17px"
      .attr "width", "100px"
      .attr "height", "35px"
      .style "fill", (d) -> d[0].color
      .on 'mouseover', -> highlight_timeline(@parentNode.parentNode)
      .on 'mouseout', -> unhighlight_timeline(@parentNode.parentNode)

    timeline_group.selectAll "g.label text"
      .append "svg:text"
      .attr "x", "20px"
      .attr "dy", "8px"
      .style "fill", "white"
      .attr "font-size", "25px"
      .text (d) -> d3.round(d[d.length - 1].price, 2) + "%"
      .on 'mouseover', -> highlight_timeline(@parentNode.parentNode)
      .on 'mouseout', -> unhighlight_timeline(@parentNode.parentNode)

    timeline_paths = timeline_group.selectAll "path.line"
      .data data

    timeline_paths.enter()
      .append "svg:path"
      .classed 'line', true
      .attr "clip-path", "url(#clip)"
      .attr "stroke-width", 2
      .attr "fill", "none"
      .style "stroke", (d) -> d[0].color
      .attr "d", (d) -> linechart d

    circles = timeline_group.selectAll "circle"
      .data (d) -> d

    circles.enter()
      .append "svg:circle"
      .filter ((d) -> d.primary is true)
      .attr "clip-path", "url(#clip)"
      .attr "r", 0
      .attr "visibility", (d) -> if d.primary then "visible" else "hidden"
      .attr "fill", "none"
      .attr "cy", (d) -> yScale d.price
      .attr "cx", (d) -> xScale(new Date d.timestamp)
      .on 'mouseover', ->
        highlight_timeline @parentNode
        d3.select(@).attr 'r', 10
      .on 'mouseout',  ->
        unhighlight_timeline @parentNode
        d3.select(@).attr 'r', 5

    brush_timelines = svg.selectAll "g.brush"
      .selectAll "g.brush_timeline"
      .data data

    brush_timelines_container = brush_timelines.enter()
      .append "svg:g"
      .classed "brush_timeline", true
      .attr 'opacity', 1
      .attr "class", (d) -> "brush_timeline " + d[0].contract_id

    brush_timelines_container.selectAll "path.line"
      .append "svg:path"
      .classed "line", true
      .attr "stroke-width", 1
      .attr "fill", "none"
      .attr "d", (d) -> brushLinechart d
      .style "stroke", (d) -> d[0].color
      .attr "d", (d) -> brushLinechart d

    # Updates
    timeline_paths.transition()
      .duration transdur
      .style "stroke", (d) -> d[0].color
      .attr "d", (d) -> linechart d

    timelines_selector.selectAll "text.legend"
      .transition()
      .duration transdur
      .style "fill", (d) -> d[0].color
      .text (d) -> "⬤ " + d[0].name
      .attr "opacity", if brush.empty() then 1 else 0

    timeline_group.selectAll "g.label"
      .transition()
      .duration transdur
      .attr "transform", (d) -> position_label d[d.length - 1]

    timelines_selector.selectAll "g.label rect"
      .transition()
      .duration transdur
      .style "fill", (d) -> d[0].color

    timelines_selector.selectAll "g.label text"
      .transition()
      .duration transdur
      .text (d) -> d3.round(d[d.length - 1].price, 2) + "%"

    circles.transition()
      .duration transdur
      .attr "r", 5
      .attr "visibility", (d) -> if d.primary then "visible" else "hidden"
      .attr "fill", (d) -> d.color
      .attr "cy", (d) -> yScale d.price
      .attr "cx", (d) -> xScale(new Date d.timestamp)

    brush_timelines_selector.selectAll "path.line"
      .transition()
      .duration transdur
      .attr "d", (d) -> brushLinechart d

    # Exits
    timelines.exit()
      .remove()

    timeline_paths.exit()
      .remove()

    circles.exit()
      .transition()
      .attr "r", 0
      .remove()

    brush_timelines.exit()
      .remove()

  true

###

prepare_data_point = (names, current_user_id, current_prices, d) =>
  _.chain d.value.prices
   .pairs()
   .map (price) ->
     contract = _.findWhere(names, {_id: price[0]})
     return {
       current_user: d.user_id is current_user_id
       trade_type: "buy" if d.value?.owned_before < d.value?.owned_after
       timestamp: d.timestamp
       contract_id: price[0]
       notmirror: contract?
       name: contract.title if contract?
       color: contract.color if contract?
       user_id: d.user_id
       price: price[1]
       primary: price[0] is d.value?.contract_id
       transaction_id: d._id
       in_progress : d.in_progress || false
       shares : Math.abs d.value?.trade_amount
       avg_price : (d.value?.cost / d.value?.trade_amount).toFixed 2
       cost : (d.value?.cost * 1).toFixed 2
       worth : (current_prices[price[0]] * (Math.abs(d.value?.trade_amount))).toFixed 2
     }
   .filter (contract) ->
     contract.notmirror is true
   .value()

drop_at_set_prices = (memo, event) ->
  unless memo
    memo = []
  if event?type is "set_prices"
    return [event]
  else
    memo.push event
    return memo

prepare_data = (log_data, names, current_user_id) ->
  prices = _.chain log_data
            .reduce drop_at_set_prices, []
            .filter (datapoint) ->
              datapoint.mirror isnt true
            .value()

  last_prices = _.chain prices
                 .flatten()
                 .sortBy "timestamp"
                 .pluck "value"
                 .pluck "prices"
                 .last()
                 .value()

  preparefunc = _.partial(prepare_data_point, names, current_user_id, last_prices)
  values = _.chain prices
            .map preparefunc
            .flatten()
            .groupBy "contract_id"
            .toArray()
            .value()

  # Some times the collection is not ready when first rendering the template.
  # In this case, return faux data to allow initilalize() to do its thing.
  if values.length < 1
    values = [[
      timestamp: Date.now() - 360000
      contract_id: "xxx"
      name: "acontract"
      color: "#550055"
      user_id: "zzz"
      price: 50
      primary: true
      transaction_id: "yyy"
    ,
      timestamp: Date.now()
      contract_id: "xxx"
      name: "acontract"
      color: "#550055"
      user_id: "zzz"
      price: 54
      primary: true
      transaction_id: "nnn"
    ]]

  return {
    chart:  values
    tooltip: []
  }

@Timeline = {}

@Timeline.initialize_graph = (svgnode) ->
  container = d3.select svgnode

  tooltip = container
    .append "div"
      .classed "trade-tooltip", true
      .style "z-index", "10"
      .style "visibility", "visible"

  svg  = container.select "svg"

  svg.append("defs").append "clipPath"
    .attr "id", "clip"
    .append "rect"
    .attr "width", width - margin_left - margin_right
    .attr "height", height - (margin_bottom * 2) - margin_top - (height * brushAreaSize)

  svg.append "svg:g"
    .classed 'y axis', true
    .attr "transform", "translate(" + (width - margin_right) +  ", 0)"

  svg.append "svg:g"
    .classed 'x axis', true
    .attr "transform", "translate(0, " + (height - margin_bottom - (height * brushAreaSize)) + ")"

  svg.append "svg:g"
    .classed 'brush x axis', true
    .attr "transform", "translate(0, " + (height - margin_bottom) + ")"

  timelines = svg.append "svg:g"
    .classed 'timelines', true

  timelines = svg.append "svg:g"
    .classed 'circles', true

  brushGroup = svg.append "svg:g"
    .classed "brush", true

  # #Removed temporary to prevent error when brushgroup is not ative
  # brushGroup.append "svg:g"
  #   .classed "x brush", true
  #   .call brush
  #   .selectAll "rect"
  #   .attr "y", height - (height * brushAreaSize)
  #   .attr "height", height * brushAreaSize - margin_bottom

  true

@Timeline.update_and_refresh_graph = (svgnode, current_user_id, data, names) ->
  refresh svgnode, prepare_data(data, names, current_user_id)
