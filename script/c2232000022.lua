--Empty, Infinite, and Infinite Light
local s,id=GetID()
function s.initial_effect(c)
	--Activate Skill
	aux.AddSkillProcedure(c,1,false,s.flipcon2,s.flipop2)
end

function s.sendToGrave(c)
	return c:IsAbleToGraveAsCost()
end


function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0 then return end
	--Boolean checks for the activation condition: b1, b2
	local b1=Duel.GetFlagEffect(tp,id+1)==0
		and Duel.IsExistingMatchingCard(s.sendToGrave,tp,LOCATION_HAND,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	local b2=Duel.GetFlagEffect(tp,id+2)==0
		and Duel.IsExistingMatchingCard(s.sendToGrave,tp,LOCATION_HAND,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0

	return aux.CanActivateSkill(tp) and (b1 or b2)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:
	local b1=Duel.GetFlagEffect(tp, id+1)==0
		and Duel.IsExistingMatchingCard(s.high_level_filter, tp, LOCATION_MZONE, 0, 1, nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0

	local b2=Duel.GetFlagEffect(tp, id+2)==0
		and Duel.IsExistingMatchingCard(s.high_level_filter, tp, LOCATION_MZONE, 0, 1, nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0

	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},
								  {b2,aux.Stringid(id,1)})
	op=op-1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	else
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	end
end

--op=0 set 1 "Empty Machine" from outside the duel to your Spell/Trap Zone.
function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	local cearth=Duel.CreateToken(tp, 9409625)
	Duel.SSet(tp,cearth)
	Duel.RegisterFlagEffect(tp,id+1,0,0,0)
end

function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	local cearth=Duel.CreateToken(tp, 9409625)
	Duel.SSet(tp,cearth)
	Duel.RegisterFlagEffect(tp,id+2,0,0,0)
end
